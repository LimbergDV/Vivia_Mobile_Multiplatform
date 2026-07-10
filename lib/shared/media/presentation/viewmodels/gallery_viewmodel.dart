import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vivia_mobile/core/utils/media_file_utils.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vivia_mobile/shared/property/domain/exceptions/media_exceptions.dart';
import 'package:vivia_mobile/shared/property/domain/models/media_manifest_item.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_media.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/add_property_media_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/change_main_image_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/delete_property_media_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_property_media_usecase.dart';

enum GalleryStatus { idle, loading, success, error }

enum PendingMediaState { uploading, inReview, failed }

/// Un medio recién subido por el lessor que aún no pasa la moderación del
/// backend. Vive solo en memoria durante la sesión de galería.
class PendingMedia {
  final String localPath;
  final String classification;
  final bool isVideo;
  final PendingMediaState state;

  const PendingMedia({
    required this.localPath,
    required this.classification,
    required this.isVideo,
    required this.state,
  });

  PendingMedia copyWith({PendingMediaState? state}) => PendingMedia(
        localPath: localPath,
        classification: classification,
        isVideo: isVideo,
        state: state ?? this.state,
      );
}

/// ViewModel de la galería de una propiedad. Concentra toda la lógica de
/// presentación: separar fotos/videos, derivar categorías desde las
/// `classification`, filtrar por la categoría seleccionada y — cuando el
/// usuario es lessor — gestionar los medios (agregar, cambiar portada,
/// eliminar).
class GalleryViewModel extends ChangeNotifier {
  static const String allCategory = 'Todas';
  static const String mainClassification = 'MAIN';

  final GetPropertyMediaUseCase _getPropertyMedia;
  final AddPropertyMediaUseCase? _addPropertyMedia;
  final ChangeMainImageUseCase? _changeMainImage;
  final DeletePropertyMediaUseCase? _deletePropertyMedia;
  final AuthRepository? _authRepository;

  GalleryViewModel({
    required GetPropertyMediaUseCase getPropertyMediaUseCase,
    AddPropertyMediaUseCase? addPropertyMediaUseCase,
    ChangeMainImageUseCase? changeMainImageUseCase,
    DeletePropertyMediaUseCase? deletePropertyMediaUseCase,
    AuthRepository? authRepository,
  })  : _getPropertyMedia = getPropertyMediaUseCase,
        _addPropertyMedia = addPropertyMediaUseCase,
        _changeMainImage = changeMainImageUseCase,
        _deletePropertyMedia = deletePropertyMediaUseCase,
        _authRepository = authRepository;

  GalleryStatus _status = GalleryStatus.idle;
  List<PropertyMedia> _media = const [];
  String _selectedCategory = allCategory;
  String? _propertyId;
  List<PendingMedia> _pending = const [];
  bool _isSubmitting = false;
  String? _actionMessage;

  GalleryStatus get status => _status;
  String get selectedCategory => _selectedCategory;

  bool get isLoading => _status == GalleryStatus.loading;
  bool get hasError => _status == GalleryStatus.error;
  bool get isSubmitting => _isSubmitting;

  /// El lessor puede gestionar los medios (la app solo le muestra sus
  /// propias propiedades; el backend valida ownership de todos modos).
  bool get canEdit =>
      _addPropertyMedia != null &&
      _changeMainImage != null &&
      _deletePropertyMedia != null &&
      _authRepository?.savedRole == 'ROLE_LESSOR';

  /// El "+" se oculta en la categoría MAIN: el POST prohíbe esa clasificación.
  bool get canAddInCurrentCategory =>
      canEdit && _selectedCategory != mainClassification;

  /// Clasificación con la que se suben fotos nuevas: la categoría activa,
  /// u OTHER cuando está en "Todas".
  String get uploadClassification =>
      _selectedCategory == allCategory ? 'OTHER' : _selectedCategory;

  /// Mensaje one-shot para SnackBars (éxito/error). Se limpia al consumirlo.
  String? consumeActionMessage() {
    final message = _actionMessage;
    _actionMessage = null;
    return message;
  }

  List<PropertyMedia> get _photos =>
      _media.where((m) => m.isImage).toList(growable: false);

  /// Videos de la propiedad (type == VIDEO).
  List<PropertyMedia> get videos =>
      _media.where((m) => m.isVideo).toList(growable: false);

  /// Categorías = "Todas" + las `classification` únicas presentes en las fotos.
  List<String> get categories {
    final classifications = _photos
        .map((m) => m.classification.trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return [allCategory, ...classifications];
  }

  /// Fotos filtradas por la categoría seleccionada.
  List<PropertyMedia> get displayedPhotos {
    if (_selectedCategory == allCategory) return _photos;
    return _photos
        .where((m) => m.classification.trim() == _selectedCategory)
        .toList(growable: false);
  }

  /// Pendientes (en subida/revisión) visibles en la categoría activa.
  List<PendingMedia> get displayedPendingPhotos => _pending
      .where((p) =>
          !p.isVideo &&
          (_selectedCategory == allCategory ||
              p.classification == _selectedCategory))
      .toList(growable: false);

  /// Videos pendientes de revisión.
  List<PendingMedia> get pendingVideos =>
      _pending.where((p) => p.isVideo).toList(growable: false);

  /// Atajo: solo las URLs de las fotos mostradas (para el visor fullscreen).
  List<String> get displayedImageUrls =>
      displayedPhotos.map((m) => m.url).toList(growable: false);

  void selectCategory(String category) {
    if (category == _selectedCategory) return;
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> load(String propertyId) async {
    if (_status == GalleryStatus.loading) return;
    _propertyId = propertyId;

    _status = GalleryStatus.loading;
    notifyListeners();

    try {
      _media = await _getPropertyMedia.execute(propertyId);
      // Si la categoría seleccionada ya no existe, vuelve a "Todas".
      if (!categories.contains(_selectedCategory)) {
        _selectedCategory = allCategory;
      }
      _status = GalleryStatus.success;
    } catch (_) {
      _status = GalleryStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> _reload() async {
    final propertyId = _propertyId;
    if (propertyId == null) return;
    _status = GalleryStatus.idle;
    await load(propertyId);
  }

  // ── Gestión de medios (solo lessor) ───────────────────────────────────────

  Future<void> addPhotos(List<String> paths) =>
      _addMedia(paths, uploadClassification, isVideo: false);

  Future<void> addVideo(String path) =>
      _addMedia([path], 'TOUR', isVideo: true);

  Future<void> _addMedia(
    List<String> paths,
    String classification, {
    required bool isVideo,
  }) async {
    final addPropertyMedia = _addPropertyMedia;
    final propertyId = _propertyId;
    if (addPropertyMedia == null || propertyId == null || paths.isEmpty) {
      return;
    }

    final manifest = <MediaManifestItem>[];
    final fileKeyToPath = <String, String>{};
    for (final path in paths) {
      final key = MediaFileUtils.uniqueFileKey(path, fileKeyToPath);
      manifest.add(
        MediaManifestItem(
          fileKey: key,
          contentType: MediaFileUtils.contentType(path),
          sizeBytes: await XFile(path).length(),
          classification: classification,
        ),
      );
      fileKeyToPath[key] = path;
    }

    final newPending = paths
        .map((path) => PendingMedia(
              localPath: path,
              classification: classification,
              isVideo: isVideo,
              state: PendingMediaState.uploading,
            ))
        .toList();
    _pending = [..._pending, ...newPending];
    _isSubmitting = true;
    notifyListeners();

    try {
      await addPropertyMedia.execute(
        propertyId: propertyId,
        manifest: manifest,
        fileKeyToPath: fileKeyToPath,
      );
      _pending = _pending
          .map((p) => newPending.contains(p)
              ? p.copyWith(state: PendingMediaState.inReview)
              : p)
          .toList();
      _actionMessage =
          'Tus medios están en revisión. Te notificaremos cuando se publiquen.';
    } catch (_) {
      _pending = _pending.where((p) => !newPending.contains(p)).toList();
      _actionMessage = 'No se pudieron subir los archivos. Intenta de nuevo.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> setAsMain(PropertyMedia media) async {
    final changeMainImage = _changeMainImage;
    if (changeMainImage == null || !media.isImage) return;

    PropertyMedia? currentMain;
    for (final m in _media) {
      if (m.isImage && m.classification.trim() == mainClassification) {
        currentMain = m;
        break;
      }
    }
    if (currentMain == null || currentMain.id == media.id) return;

    _isSubmitting = true;
    notifyListeners();

    try {
      await changeMainImage.execute(
        mainImageId: currentMain.id,
        newMainImageId: media.id,
      );
      _actionMessage = 'Imagen principal actualizada.';
      _isSubmitting = false;
      await _reload();
    } catch (_) {
      _actionMessage =
          'No se pudo cambiar la imagen principal. Intenta de nuevo.';
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Elimina un medio. Devuelve true si se eliminó (para que la vista
  /// cierre el visor).
  Future<bool> deleteMedia(PropertyMedia media) async {
    final deletePropertyMedia = _deletePropertyMedia;
    if (deletePropertyMedia == null) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      await deletePropertyMedia.execute(media.id);
      _media = _media.where((m) => m.id != media.id).toList(growable: false);
      if (!categories.contains(_selectedCategory)) {
        _selectedCategory = allCategory;
      }
      _actionMessage = 'Medio eliminado.';
      return true;
    } on MainImageDeletionException {
      _actionMessage =
          'No puedes eliminar la portada. Primero elige otra imagen principal.';
      return false;
    } catch (_) {
      _actionMessage = 'No se pudo eliminar el medio. Intenta de nuevo.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

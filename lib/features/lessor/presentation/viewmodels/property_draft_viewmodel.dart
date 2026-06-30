import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vivia_mobile/features/home/domain/models/property_type_model.dart';
import 'package:vivia_mobile/features/lessor/data/models/amenity_model.dart';
import 'package:vivia_mobile/features/lessor/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/domain/models/media_manifest_item.dart';
import 'package:vivia_mobile/features/lessor/domain/models/new_property_form.dart';
import 'package:vivia_mobile/features/lessor/domain/usecases/get_amenities_usecase.dart';
import 'package:vivia_mobile/features/lessor/domain/usecases/get_neighborhoods_usecase.dart';
import 'package:vivia_mobile/features/lessor/domain/usecases/publish_property_draft_usecase.dart';

enum NeighborhoodsStatus { idle, loading, success, error }

enum AmenitiesStatus { idle, loading, success, error }

enum PublishStatus { idle, loading, success, error }

class PropertyDraftViewModel extends ChangeNotifier {
  final GetNeighborhoodsUseCase _getNeighborhoods;
  final GetAmenitiesUseCase _getAmenities;
  final PublishPropertyDraftUseCase _publishDraft;
  final void Function(bool success, String? errorMessage)? _onPublishComplete;

  PropertyDraftViewModel({
    required GetNeighborhoodsUseCase getNeighborhoodsUseCase,
    required GetAmenitiesUseCase getAmenitiesUseCase,
    required PublishPropertyDraftUseCase publishPropertyDraftUseCase,
    void Function(bool success, String? errorMessage)? onPublishComplete,
  })  : _getNeighborhoods = getNeighborhoodsUseCase,
        _getAmenities = getAmenitiesUseCase,
        _publishDraft = publishPropertyDraftUseCase,
        _onPublishComplete = onPublishComplete;

  // ── Estado ────────────────────────────────────────────────────────────────
  NewPropertyForm _form = const NewPropertyForm();
  List<NeighborhoodModel> _neighborhoods = [];
  List<AmenityModel> _amenities = [];
  NeighborhoodsStatus _neighborhoodsStatus = NeighborhoodsStatus.idle;
  AmenitiesStatus _amenitiesStatus = AmenitiesStatus.idle;
  PublishStatus _publishStatus = PublishStatus.idle;
  String? _publishError;

  // ── Getters ───────────────────────────────────────────────────────────────
  NewPropertyForm get form => _form;
  List<NeighborhoodModel> get neighborhoods => _neighborhoods;
  List<AmenityModel> get amenities => _amenities;
  NeighborhoodsStatus get neighborhoodsStatus => _neighborhoodsStatus;
  AmenitiesStatus get amenitiesStatus => _amenitiesStatus;
  PublishStatus get publishStatus => _publishStatus;
  String? get publishError => _publishError;

  // ── Inicialización ────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_amenitiesStatus != AmenitiesStatus.idle) return;
    _amenitiesStatus = AmenitiesStatus.loading;
    notifyListeners();
    try {
      _amenities = await _getAmenities.execute();
      _amenitiesStatus = AmenitiesStatus.success;
    } catch (_) {
      _amenitiesStatus = AmenitiesStatus.error;
    } finally {
      notifyListeners();
    }
  }

  // No toca _publishStatus/_publishError: esos reflejan la publicación en
  // curso en segundo plano, que puede seguir viva después de iniciar un
  // borrador nuevo.
  void reset() {
    _form = const NewPropertyForm();
    _neighborhoods = [];
    _neighborhoodsStatus = NeighborhoodsStatus.idle;
    notifyListeners();
  }

  // ── Campos del formulario Paso 1 ──────────────────────────────────────────
  void setListingType(bool isAvailableToRent) {
    _form = _form.copyWith(isAvailableToRent: isAvailableToRent);
    notifyListeners();
  }

  void setPostalCode(String cp) {
    _form = _form.copyWith(postalCode: cp);
    // Limpiar colonia seleccionada cuando cambia el CP
    _form = _form.copyWith(neighborhood: null);
    _neighborhoods = [];
    _neighborhoodsStatus = NeighborhoodsStatus.idle;
    notifyListeners();
    if (cp.length == 5) fetchNeighborhoods(cp);
  }

  void setNeighborhood(NeighborhoodModel neighborhood) {
    _form = _form.copyWith(neighborhood: neighborhood);
    notifyListeners();
  }

  void setPropertyType(PropertyTypeModel propertyType) {
    _form = _form.copyWith(propertyType: propertyType);
    notifyListeners();
  }

  void setStreet(String street) {
    _form = _form.copyWith(street: street);
    notifyListeners();
  }

  void setExteriorNumber(String number) {
    _form = _form.copyWith(exteriorNumber: number);
    notifyListeners();
  }

  void setInteriorNumber(String number) {
    _form = _form.copyWith(interiorNumber: number);
    notifyListeners();
  }

  void setPrice(String price) {
    _form = _form.copyWith(price: price);
    notifyListeners();
  }

  void setArea(String area) {
    _form = _form.copyWith(area: area);
    notifyListeners();
  }

  // ── Campos del formulario Paso 2 ──────────────────────────────────────────
  void setRooms(int rooms) {
    _form = _form.copyWith(rooms: rooms);
    notifyListeners();
  }

  void setBathrooms(int bathrooms) {
    _form = _form.copyWith(bathrooms: bathrooms);
    notifyListeners();
  }

  void setParkingSpots(int spots) {
    _form = _form.copyWith(parkingSpots: spots);
    notifyListeners();
  }

  void setTitle(String title) {
    _form = _form.copyWith(title: title);
    notifyListeners();
  }

  void setDescription(String description) {
    _form = _form.copyWith(description: description);
    notifyListeners();
  }

  void setConstructionYear(int? year) {
    _form = _form.copyWith(constructionYear: year);
    notifyListeners();
  }

  void setIsCondominium(bool value) {
    _form = _form.copyWith(isCondominium: value);
    notifyListeners();
  }

  void toggleAmenity(String id) {
    final current = List<String>.from(_form.amenityIds);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    _form = _form.copyWith(amenityIds: current);
    notifyListeners();
  }

  // ── Campos multimedia ─────────────────────────────────────────────────────
  void setMainPhotoPath(String path) {
    _form = _form.copyWith(mainPhotoPath: path);
    notifyListeners();
  }

  void setSpacePhotos(Map<String, List<String>> photos) {
    _form = _form.copyWith(spacePhotos: photos);
    notifyListeners();
  }

  void setVideoPath(String? path) {
    _form = _form.copyWith(videoPath: path);
    notifyListeners();
  }

  // ── Colonias dinámicas ────────────────────────────────────────────────────
  Future<void> fetchNeighborhoods(String cp) async {
    _neighborhoodsStatus = NeighborhoodsStatus.loading;
    notifyListeners();
    try {
      _neighborhoods = await _getNeighborhoods.execute(cp);
      _neighborhoodsStatus = NeighborhoodsStatus.success;
    } catch (_) {
      _neighborhoods = [];
      _neighborhoodsStatus = NeighborhoodsStatus.error;
    } finally {
      notifyListeners();
    }
  }

  // ── Publicación: dos fases ────────────────────────────────────────────────
  //
  // Se llama sin `await` desde la pantalla de revisión: el formBody se
  // captura de forma síncrona (antes del primer `await` de este método),
  // así que el caller puede resetear el formulario inmediatamente después
  // de invocar `publish()` sin afectar los datos que se están publicando.
  Future<void> publish({
    required String mainPhotoPath,
    required Map<String, List<String>> spacePhotos,
    String? videoPath,
  }) async {
    if (_publishStatus == PublishStatus.loading) return;

    _publishStatus = PublishStatus.loading;
    _publishError = null;
    notifyListeners();

    final formBody = _buildFormBody();

    try {
      final manifest = <MediaManifestItem>[];
      final fileKeyToPath = <String, String>{};

      // Foto principal → classification MAIN
      final mainKey = _fileKey(mainPhotoPath);
      manifest.add(MediaManifestItem(
        fileKey: mainKey,
        contentType: _contentType(mainPhotoPath),
        sizeBytes: await XFile(mainPhotoPath).length(),
        classification: 'MAIN',
      ));
      fileKeyToPath[mainKey] = mainPhotoPath;

      // Fotos de espacios → classification = nombre de categoría en MAYÚSCULAS
      for (final entry in spacePhotos.entries) {
        final classification = entry.key.toUpperCase();
        for (final path in entry.value) {
          final key = _uniqueFileKey(path, fileKeyToPath);
          manifest.add(MediaManifestItem(
            fileKey: key,
            contentType: _contentType(path),
            sizeBytes: await XFile(path).length(),
            classification: classification,
          ));
          fileKeyToPath[key] = path;
        }
      }

      // Video → classification TOUR
      if (videoPath != null) {
        final videoKey = _uniqueFileKey(videoPath, fileKeyToPath);
        manifest.add(MediaManifestItem(
          fileKey: videoKey,
          contentType: 'video/mp4',
          sizeBytes: await XFile(videoPath).length(),
          classification: 'TOUR',
        ));
        fileKeyToPath[videoKey] = videoPath;
      }

      await _publishDraft.execute(
        formBody: formBody,
        manifest: manifest,
        fileKeyToPath: fileKeyToPath,
      );

      _publishStatus = PublishStatus.success;
      _onPublishComplete?.call(true, null);
    } catch (e) {
      _publishStatus = PublishStatus.error;
      _publishError = e.toString();
      _onPublishComplete?.call(false, _publishError);
    } finally {
      notifyListeners();
    }
  }

  Map<String, dynamic> _buildFormBody() {
    return {
      'propertyTypeId': _form.propertyType!.id,
      'neighborhoodId': _form.neighborhood!.id,
      'street': _form.street ?? '',
      'exteriorNumber': _form.exteriorNumber ?? '',
      if (_form.interiorNumber != null && _form.interiorNumber!.isNotEmpty)
        'interiorNumber': _form.interiorNumber,
      'isAvailableToRent': _form.isAvailableToRent,
      'title': _form.title ?? '',
      'description': _form.description ?? '',
      'areaM2': double.tryParse(_form.area ?? '0') ?? 0.0,
      'bedrooms': _form.rooms ?? 0,
      'bathrooms': (_form.bathrooms ?? 0).toDouble(),
      'parkingSpaces': _form.parkingSpots ?? 0,
      if (_form.constructionYear != null)
        'constructionYear': _form.constructionYear,
      'isCondominium': _form.isCondominium,
      'listedPrice': double.tryParse(_form.price ?? '0') ?? 0.0,
      'amenityIds': _form.amenityIds,
    };
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _fileKey(String path) {
    final filename = path.split('/').last.split('\\').last;
    final dotIndex = filename.lastIndexOf('.');
    return dotIndex != -1 ? filename.substring(0, dotIndex) : filename;
  }

  String _uniqueFileKey(String path, Map<String, String> existing) {
    String key = _fileKey(path);
    int suffix = 1;
    while (existing.containsKey(key)) {
      key = '${_fileKey(path)}_$suffix';
      suffix++;
    }
    return key;
  }

  String _contentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'mp4' => 'video/mp4',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}
import 'package:flutter/material.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_media.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_property_media_usecase.dart';

enum GalleryStatus { idle, loading, success, error }

/// ViewModel de la galería de una propiedad. Concentra toda la lógica de
/// presentación: separar fotos/videos, derivar categorías desde las
/// `classification` y filtrar por la categoría seleccionada.
class GalleryViewModel extends ChangeNotifier {
  static const String allCategory = 'Todas';

  final GetPropertyMediaUseCase _getPropertyMedia;

  GalleryViewModel({required GetPropertyMediaUseCase getPropertyMediaUseCase})
      : _getPropertyMedia = getPropertyMediaUseCase;

  GalleryStatus _status = GalleryStatus.idle;
  List<PropertyMedia> _media = const [];
  String _selectedCategory = allCategory;

  GalleryStatus get status => _status;
  String get selectedCategory => _selectedCategory;

  bool get isLoading => _status == GalleryStatus.loading;
  bool get hasError => _status == GalleryStatus.error;

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
}

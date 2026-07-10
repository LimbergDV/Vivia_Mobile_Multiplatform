import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_model.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_type_model.dart';
import 'package:vivia_mobile/shared/property/domain/models/selected_category.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_properties_me_likes_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_properties_me_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_properties_near_me_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_property_suggestions_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_property_types_usecase.dart';

enum PropertyLoadStatus { idle, loading, success, error }

class PropertyViewModel extends ChangeNotifier {
  final GetPropertyTypesUseCase _getPropertyTypes;
  final GetPropertiesMeUseCase _getPropertiesMe;
  final GetPropertiesMeLikesUseCase _getPropertiesMeLikes;
  final GetPropertySuggestionsUseCase _getPropertySuggestions;
  final GetPropertiesNearMeUseCase _getPropertiesNearMe;
  final AuthRepository _authRepository;

  PropertyViewModel({
    required GetPropertyTypesUseCase getPropertyTypesUseCase,
    required GetPropertiesMeUseCase getPropertiesMeUseCase,
    required GetPropertiesMeLikesUseCase getPropertiesMeLikesUseCase,
    required GetPropertySuggestionsUseCase getPropertySuggestionsUseCase,
    required GetPropertiesNearMeUseCase getPropertiesNearMeUseCase,
    required AuthRepository authRepository,
  })  : _getPropertyTypes = getPropertyTypesUseCase,
        _getPropertiesMe = getPropertiesMeUseCase,
        _getPropertiesMeLikes = getPropertiesMeLikesUseCase,
        _getPropertySuggestions = getPropertySuggestionsUseCase,
        _getPropertiesNearMe = getPropertiesNearMeUseCase,
        _authRepository = authRepository;

  PropertyLoadStatus _typesStatus = PropertyLoadStatus.idle;
  PropertyLoadStatus _propertiesStatus = PropertyLoadStatus.idle;

  PropertyLoadStatus get typesStatus => _typesStatus;
  PropertyLoadStatus get propertiesStatus => _propertiesStatus;

  List<SelectedCategory> _categoryTabs = const [AllCategory()];
  SelectedCategory _selectedCategory = const AllCategory();
  List<PropertyModel> _allProperties = [];
  List<PropertyModel> _likedProperties = [];
  List<PropertyModel> _nearbyProperties = [];

  List<SelectedCategory> get categoryTabs => _categoryTabs;
  SelectedCategory get selectedCategory => _selectedCategory;

  List<PropertyModel> get displayedProperties => switch (_selectedCategory) {
    AllCategory() => _allProperties,
    FavoritesCategory() => _likedProperties,
    TypeCategory(type: final t) =>
        _allProperties.where((p) => p.type == t.name).toList(),
  };

  List<PropertyModel> get nearbyProperties => _nearbyProperties;

  bool get isLessor => _authRepository.savedRole == 'ROLE_LESSOR';

  List<PropertyTypeModel> get propertyTypes => _categoryTabs
      .whereType<TypeCategory>()
      .map((c) => c.type)
      .toList();

  Future<void> init() async {
    if (_typesStatus != PropertyLoadStatus.idle) return;

    final isLessor = _authRepository.savedRole == 'ROLE_LESSOR';

    _typesStatus = PropertyLoadStatus.loading;
    _propertiesStatus = PropertyLoadStatus.loading;
    notifyListeners();

    // Carga tipos, propiedades y likes en paralelo; al terminar sincroniza isFavorite
    await Future.wait([
      _loadTypes(),
      isLessor ? _loadPropertiesMe() : _loadPropertySuggestions(),
      if (!isLessor) _loadNearby(),
      _loadLikesEager(),
    ]);
    _syncLikedIntoAll();
    notifyListeners();
  }

  Future<void> _loadTypes() async {
    try {
      final types = await _getPropertyTypes.execute();
      _categoryTabs = [
        const AllCategory(),
        ...types.map(TypeCategory.new),
        const FavoritesCategory(),
      ];
      _typesStatus = PropertyLoadStatus.success;
    } catch (_) {
      _typesStatus = PropertyLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadPropertiesMe() async {
    try {
      _allProperties = await _getPropertiesMe.execute();
      _propertiesStatus = PropertyLoadStatus.success;
    } catch (_) {
      _propertiesStatus = PropertyLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadPropertySuggestions() async {
    try {
      _allProperties = await _getPropertySuggestions.execute();
      _propertiesStatus = PropertyLoadStatus.success;
    } catch (e) {
      debugPrint('ERROR suggestions: $e');
      _propertiesStatus = PropertyLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final isLessor = _authRepository.savedRole == 'ROLE_LESSOR';

    _propertiesStatus = PropertyLoadStatus.loading;
    notifyListeners();

    await Future.wait([
      _loadTypes(),
      isLessor ? _loadPropertiesMe() : _loadPropertySuggestions(),
      if (!isLessor) _loadNearby(),
      if (_selectedCategory is FavoritesCategory) _loadLikes(),
    ]);
  }

  Future<void> selectCategory(SelectedCategory category) async {
    _selectedCategory = category;
    notifyListeners();

    if (category is FavoritesCategory && _likedProperties.isEmpty) {
      await _loadLikes();
    }
  }

  Future<void> _loadLikes() async {
    _propertiesStatus = PropertyLoadStatus.loading;
    notifyListeners();
    try {
      _likedProperties = await _getPropertiesMeLikes.execute();
      _syncLikedIntoAll();
      _propertiesStatus = PropertyLoadStatus.success;
    } catch (_) {
      _propertiesStatus = PropertyLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  // Carga silenciosa: si /properties/nearme falla, la sección se oculta sola
  Future<void> _loadNearby() async {
    try {
      _nearbyProperties = await _getPropertiesNearMe.execute();
      debugPrint('[nearme] OK: ${_nearbyProperties.length} propiedades');
    } catch (e) {
      debugPrint('[nearme] ERROR: $e');
      _nearbyProperties = [];
    } finally {
      notifyListeners();
    }
  }

  // Carga silenciosa de favoritos sin tocar propertiesStatus (usada en init)
  Future<void> _loadLikesEager() async {
    try {
      _likedProperties = await _getPropertiesMeLikes.execute();
    } catch (_) {}
  }

  // Marca isFavorite: true en _allProperties y _nearbyProperties para items
  // que estén en _likedProperties
  void _syncLikedIntoAll() {
    if (_likedProperties.isEmpty) return;
    final likedIds = {for (final p in _likedProperties) p.id};
    _allProperties = _markFavorites(_allProperties, likedIds);
    _nearbyProperties = _markFavorites(_nearbyProperties, likedIds);
  }

  List<PropertyModel> _markFavorites(
      List<PropertyModel> list, Set<String> likedIds) {
    if (list.isEmpty) return list;
    return list.map((p) {
      if (!likedIds.contains(p.id)) return p;
      return PropertyModel(
        id: p.id, title: p.title, type: p.type, price: p.price,
        location: p.location, area: p.area, bedrooms: p.bedrooms,
        bathrooms: p.bathrooms, imageUrl: p.imageUrl, isFavorite: true,
      );
    }).toList();
  }

  void prependProperty(PropertyModel property) {
    _allProperties = [property, ..._allProperties];
    notifyListeners();
  }

  void removeProperty(String propertyId) {
    _allProperties = _allProperties.where((p) => p.id != propertyId).toList();
    _likedProperties = _likedProperties.where((p) => p.id != propertyId).toList();
    _nearbyProperties = _nearbyProperties.where((p) => p.id != propertyId).toList();
    notifyListeners();
  }

  void updatePropertyLike(String propertyId, bool liked) {
    PropertyModel? updated;
    List<PropertyModel> apply(List<PropertyModel> list) => list.map((p) {
      if (p.id != propertyId) return p;
      updated = PropertyModel(
        id: p.id,
        title: p.title,
        type: p.type,
        price: p.price,
        location: p.location,
        area: p.area,
        bedrooms: p.bedrooms,
        bathrooms: p.bathrooms,
        imageUrl: p.imageUrl,
        isFavorite: liked,
      );
      return updated!;
    }).toList();

    _allProperties = apply(_allProperties);
    _nearbyProperties = apply(_nearbyProperties);

    if (liked) {
      if (updated != null && !_likedProperties.any((p) => p.id == propertyId)) {
        _likedProperties = [updated!, ..._likedProperties];
      }
    } else {
      _likedProperties = _likedProperties.where((p) => p.id != propertyId).toList();
    }

    notifyListeners();
  }

  void reset() {
    _typesStatus = PropertyLoadStatus.idle;
    _propertiesStatus = PropertyLoadStatus.idle;
    _categoryTabs = const [AllCategory()];
    _selectedCategory = const AllCategory();
    _allProperties = [];
    _likedProperties = [];
    _nearbyProperties = [];
    notifyListeners();
  }
}
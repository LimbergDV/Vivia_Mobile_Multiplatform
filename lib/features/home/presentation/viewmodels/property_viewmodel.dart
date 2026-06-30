import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vivia_mobile/features/home/domain/models/property_model.dart';
import 'package:vivia_mobile/features/home/domain/models/property_type_model.dart';
import 'package:vivia_mobile/features/home/domain/models/selected_category.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_properties_me_likes_usecase.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_properties_me_usecase.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_property_suggestions_usecase.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_property_types_usecase.dart';

enum PropertyLoadStatus { idle, loading, success, error }

class PropertyViewModel extends ChangeNotifier {
  final GetPropertyTypesUseCase _getPropertyTypes;
  final GetPropertiesMeUseCase _getPropertiesMe;
  final GetPropertiesMeLikesUseCase _getPropertiesMeLikes;
  final GetPropertySuggestionsUseCase _getPropertySuggestions;
  final AuthRepository _authRepository;

  PropertyViewModel({
    required GetPropertyTypesUseCase getPropertyTypesUseCase,
    required GetPropertiesMeUseCase getPropertiesMeUseCase,
    required GetPropertiesMeLikesUseCase getPropertiesMeLikesUseCase,
    required GetPropertySuggestionsUseCase getPropertySuggestionsUseCase,
    required AuthRepository authRepository,
  })  : _getPropertyTypes = getPropertyTypesUseCase,
        _getPropertiesMe = getPropertiesMeUseCase,
        _getPropertiesMeLikes = getPropertiesMeLikesUseCase,
        _getPropertySuggestions = getPropertySuggestionsUseCase,
        _authRepository = authRepository;

  PropertyLoadStatus _typesStatus = PropertyLoadStatus.idle;
  PropertyLoadStatus _propertiesStatus = PropertyLoadStatus.idle;

  PropertyLoadStatus get typesStatus => _typesStatus;
  PropertyLoadStatus get propertiesStatus => _propertiesStatus;

  List<SelectedCategory> _categoryTabs = const [AllCategory()];
  SelectedCategory _selectedCategory = const AllCategory();
  List<PropertyModel> _allProperties = [];
  List<PropertyModel> _likedProperties = [];

  List<SelectedCategory> get categoryTabs => _categoryTabs;
  SelectedCategory get selectedCategory => _selectedCategory;

  List<PropertyModel> get displayedProperties => switch (_selectedCategory) {
    AllCategory() => _allProperties,
    FavoritesCategory() => _likedProperties,
    TypeCategory(type: final t) =>
        _allProperties.where((p) => p.type == t.name).toList(),
  };

  List<PropertyModel> get nearbyProperties => _allProperties.take(4).toList();

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

    await Future.wait([
      _loadTypes(),
      isLessor ? _loadPropertiesMe() : _loadPropertySuggestions(),
    ]);
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
      _propertiesStatus = PropertyLoadStatus.success;
    } catch (_) {
      _propertiesStatus = PropertyLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _typesStatus = PropertyLoadStatus.idle;
    _propertiesStatus = PropertyLoadStatus.idle;
    _categoryTabs = const [AllCategory()];
    _selectedCategory = const AllCategory();
    _allProperties = [];
    _likedProperties = [];
    notifyListeners();
  }
}
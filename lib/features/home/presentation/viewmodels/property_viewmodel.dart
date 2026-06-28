import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vivia_mobile/features/home/domain/models/property_model.dart';
import 'package:vivia_mobile/features/home/domain/models/selected_category.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_properties_me_likes_usecase.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_properties_me_usecase.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_property_types_usecase.dart';

enum PropertyLoadStatus { idle, loading, success, error }

class PropertyViewModel extends ChangeNotifier {
  final GetPropertyTypesUseCase _getPropertyTypes;
  final GetPropertiesMeUseCase _getPropertiesMe;
  final GetPropertiesMeLikesUseCase _getPropertiesMeLikes;
  final AuthRepository _authRepository;

  PropertyViewModel({
    required GetPropertyTypesUseCase getPropertyTypesUseCase,
    required GetPropertiesMeUseCase getPropertiesMeUseCase,
    required GetPropertiesMeLikesUseCase getPropertiesMeLikesUseCase,
    required AuthRepository authRepository,
  })  : _getPropertyTypes = getPropertyTypesUseCase,
        _getPropertiesMe = getPropertiesMeUseCase,
        _getPropertiesMeLikes = getPropertiesMeLikesUseCase,
        _authRepository = authRepository;

  // ── Estado ────────────────────────────────────────────────────────────────
  PropertyLoadStatus _typesStatus = PropertyLoadStatus.idle;
  PropertyLoadStatus _propertiesStatus = PropertyLoadStatus.idle;

  PropertyLoadStatus get typesStatus => _typesStatus;
  PropertyLoadStatus get propertiesStatus => _propertiesStatus;

  // ── Datos ─────────────────────────────────────────────────────────────────
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

  // Primeros 4 ítems de /properties/me para la sección "Cerca de ti"
  List<PropertyModel> get nearbyProperties => _allProperties.take(4).toList();

  bool get isLessor => _authRepository.savedRole == 'ROLE_LESSOR';

  // ── Inicialización ────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_typesStatus != PropertyLoadStatus.idle) return;

    final isLessor = _authRepository.savedRole == 'ROLE_LESSOR';

    if (!isLessor) {
      // Endpoints aún no disponibles para lessee — UI responde con estado vacío limpio
      _typesStatus = PropertyLoadStatus.success;
      _propertiesStatus = PropertyLoadStatus.success;
      notifyListeners();
      return;
    }

    _typesStatus = PropertyLoadStatus.loading;
    _propertiesStatus = PropertyLoadStatus.loading;
    notifyListeners();

    await Future.wait([
      _loadTypes(),
      _loadPropertiesMe(),
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

  // ── Selección de categoría ────────────────────────────────────────────────
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
}

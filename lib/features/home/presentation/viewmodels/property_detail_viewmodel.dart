import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/home/domain/models/property_detail.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_property_by_id_usecase.dart';
import 'package:vivia_mobile/features/home/domain/usecases/toggle_like_usecase.dart';

enum PropertyDetailStatus { idle, loading, success, error }

/// ViewModel del detalle de una propiedad. Se instancia una vez por pantalla
/// de detalle (es per-propiedad, no global).
class PropertyDetailViewModel extends ChangeNotifier {
  final GetPropertyByIdUseCase _getPropertyById;
  final ToggleLikeUseCase _toggleLike;

  PropertyDetailViewModel({
    required GetPropertyByIdUseCase getPropertyByIdUseCase,
    required ToggleLikeUseCase toggleLikeUseCase,
  })  : _getPropertyById = getPropertyByIdUseCase,
        _toggleLike = toggleLikeUseCase;

  PropertyDetailStatus _status = PropertyDetailStatus.idle;
  PropertyDetail? _detail;
  bool? _localLike;

  PropertyDetailStatus get status => _status;
  PropertyDetail? get detail => _detail;

  bool get currentLike => _localLike ?? _detail?.like ?? false;

  Future<void> load(String id) async {
    if (_status == PropertyDetailStatus.loading) return;

    _status = PropertyDetailStatus.loading;
    notifyListeners();

    try {
      _detail = await _getPropertyById.execute(id);
      _status = PropertyDetailStatus.success;
    } catch (_) {
      _status = PropertyDetailStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> toggleLike(String propertyId) async {
    final previous = currentLike;
    _localLike = !previous;
    notifyListeners();

    try {
      final confirmed = await _toggleLike.execute(propertyId);
      _localLike = confirmed;
    } catch (_) {
      _localLike = previous;
    } finally {
      notifyListeners();
    }
  }
}

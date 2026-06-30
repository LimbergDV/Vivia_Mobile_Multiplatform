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
  final void Function(String propertyId, bool liked)? onLikeChanged;
  final bool _initialLike;

  PropertyDetailViewModel({
    required GetPropertyByIdUseCase getPropertyByIdUseCase,
    required ToggleLikeUseCase toggleLikeUseCase,
    bool initialLike = false,
    this.onLikeChanged,
  })  : _getPropertyById = getPropertyByIdUseCase,
        _toggleLike = toggleLikeUseCase,
        _initialLike = initialLike;

  PropertyDetailStatus _status = PropertyDetailStatus.idle;
  PropertyDetail? _detail;
  bool? _localLike;

  PropertyDetailStatus get status => _status;
  PropertyDetail? get detail => _detail;

  // _localLike: acción explícita del usuario en esta sesión (optimistic)
  // _initialLike: si es true (item en Favoritos), se respeta siempre — ignora al server
  // _detail?.like: fallback cuando _initialLike = false (item de Todas/Casas) para leer del server
  bool get currentLike => _localLike ?? (_initialLike || (_detail?.like ?? false));

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
      onLikeChanged?.call(propertyId, confirmed);
    } catch (_) {
      _localLike = previous;
    } finally {
      notifyListeners();
    }
  }
}

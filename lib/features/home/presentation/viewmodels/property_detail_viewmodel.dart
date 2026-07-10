import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/maps/domain/models/geocode_result.dart';
import 'package:vivia_mobile/features/maps/domain/usecases/geocode_address_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_detail.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_property_by_id_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/toggle_like_usecase.dart';

enum PropertyDetailStatus { idle, loading, success, error }

enum PropertyMapStatus { loading, ready, unavailable }

/// ViewModel del detalle de una propiedad. Se instancia una vez por pantalla
/// de detalle (es per-propiedad, no global).
class PropertyDetailViewModel extends ChangeNotifier {
  final GetPropertyByIdUseCase _getPropertyById;
  final ToggleLikeUseCase _toggleLike;
  final GeocodeAddressUseCase? _geocodeAddress;
  final void Function(String propertyId, bool liked)? onLikeChanged;
  final bool _initialLike;

  PropertyDetailViewModel({
    required GetPropertyByIdUseCase getPropertyByIdUseCase,
    required ToggleLikeUseCase toggleLikeUseCase,
    GeocodeAddressUseCase? geocodeAddressUseCase,
    bool initialLike = false,
    this.onLikeChanged,
  })  : _getPropertyById = getPropertyByIdUseCase,
        _toggleLike = toggleLikeUseCase,
        _geocodeAddress = geocodeAddressUseCase,
        _initialLike = initialLike;

  PropertyDetailStatus _status = PropertyDetailStatus.idle;
  PropertyDetail? _detail;
  bool? _localLike;
  PropertyMapStatus _mapStatus = PropertyMapStatus.loading;
  GeocodeResult? _mapPoint;

  PropertyDetailStatus get status => _status;
  PropertyDetail? get detail => _detail;
  PropertyMapStatus get mapStatus => _mapStatus;
  GeocodeResult? get mapPoint => _mapPoint;

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
      _resolveMapPoint();
    } catch (_) {
      _status = PropertyDetailStatus.error;
      _mapStatus = PropertyMapStatus.unavailable;
    } finally {
      notifyListeners();
    }
  }

  /// Si el detalle trae coordenadas persistidas las usa directo (pin exacto,
  /// sin llamar al servicio). Solo cuando vienen nulas geocodifica con el
  /// endpoint estructurado (/geocode/address) mandando todos los campos de
  /// la dirección; null (404) = fuera de zona de servicio → mapa oculto.
  Future<void> _resolveMapPoint() async {
    final detail = _detail;
    final lat = detail?.latitude;
    final lon = detail?.longitude;
    if (detail != null && lat != null && lon != null) {
      _mapPoint = GeocodeResult(
        lat: lat,
        lon: lon,
        displayName: detail.address.formatted,
        precision: GeocodePrecision.exact,
      );
      _mapStatus = PropertyMapStatus.ready;
      notifyListeners();
      return;
    }

    final geocode = _geocodeAddress;
    final address = detail?.address;
    final postalCode = address?.neighborhood.postalCode.trim() ?? '';
    if (geocode == null || address == null || postalCode.length != 5) {
      _mapStatus = PropertyMapStatus.unavailable;
      return;
    }

    try {
      final result = await geocode.execute(
        cp: postalCode,
        street: address.street,
        exteriorNumber: address.exteriorNumber,
        neighborhood: address.neighborhood.name,
      );
      if (result != null) {
        _mapPoint = result;
        _mapStatus = PropertyMapStatus.ready;
      } else {
        _mapStatus = PropertyMapStatus.unavailable;
      }
    } catch (_) {
      // El mapa es secundario: si el servicio falla, solo se oculta.
      _mapStatus = PropertyMapStatus.unavailable;
    }
    notifyListeners();
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

import 'package:vivia_mobile/features/maps/domain/models/geocode_result.dart';

abstract class MapsRepository {
  /// Mejor candidato para [query], o null si el servicio no encontró nada.
  Future<GeocodeResult?> geocodeAddress(String query);
}

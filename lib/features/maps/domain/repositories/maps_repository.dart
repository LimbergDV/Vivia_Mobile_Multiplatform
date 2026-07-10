import 'package:vivia_mobile/features/maps/domain/models/geocode_result.dart';

abstract class MapsRepository {
  /// Mejor punto para la dirección estructurada, o null si el servicio
  /// no la resolvió dentro de la zona (404).
  Future<GeocodeResult?> geocodeAddress({
    required String cp,
    String? street,
    String? exteriorNumber,
    String? neighborhood,
  });

  /// Dirección legible de una coordenada, o null si no hay nada cerca.
  Future<String?> reverseGeocode(double lat, double lon);
}

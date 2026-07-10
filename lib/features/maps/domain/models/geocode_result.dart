/// Nivel de resolución del geocoding estructurado (semáforo de calidad).
enum GeocodePrecision {
  /// Encontró el número de casa: pin directo, confianza total.
  exact,

  /// Centro de la calle: pin razonable; ofrecer ajuste fino.
  street,

  /// Centro de la colonia: centrar mapa y pedir pin manual.
  neighbourhood,

  /// Centroide del CP (~zona amplia): solo para centrar; exige pin manual.
  postcode,
}

/// Ubicación resuelta por el servicio de mapas.
class GeocodeResult {
  final double lat;
  final double lon;
  final String displayName;
  final GeocodePrecision precision;

  const GeocodeResult({
    required this.lat,
    required this.lon,
    required this.displayName,
    required this.precision,
  });

  /// true cuando el servicio solo resolvió a nivel colonia o CP.
  bool get isApproximate =>
      precision == GeocodePrecision.neighbourhood ||
      precision == GeocodePrecision.postcode;
}

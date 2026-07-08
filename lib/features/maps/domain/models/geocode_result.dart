/// Ubicación resuelta por el servicio de mapas.
class GeocodeResult {
  final double lat;
  final double lon;
  final String displayName;

  /// true cuando el servicio solo resolvió a nivel calle o zona
  /// (en OSM Chiapas los números exteriores casi nunca existen).
  final bool isApproximate;

  const GeocodeResult({
    required this.lat,
    required this.lon,
    required this.displayName,
    required this.isApproximate,
  });
}

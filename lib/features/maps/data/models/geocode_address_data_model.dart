/// Resultado de `GET /geocode/address` (geocoding estructurado).
/// `precision` indica el nivel de resolución: exact | street |
/// neighbourhood | postcode.
class GeocodeAddressDataModel {
  final double lat;
  final double lon;
  final String displayName;
  final String precision;
  final String? municipality;
  final String? postcode;

  const GeocodeAddressDataModel({
    required this.lat,
    required this.lon,
    required this.displayName,
    required this.precision,
    this.municipality,
    this.postcode,
  });

  factory GeocodeAddressDataModel.fromJson(Map<String, dynamic> json) =>
      GeocodeAddressDataModel(
        lat: (json['lat'] as num).toDouble(),
        lon: (json['lon'] as num).toDouble(),
        displayName: json['display_name'] as String? ?? '',
        precision: json['precision'] as String? ?? '',
        municipality: json['municipality'] as String?,
        postcode: json['postcode'] as String?,
      );
}

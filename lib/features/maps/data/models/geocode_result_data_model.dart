/// Candidato de geocodificación tal como lo devuelve `GET /geocode`.
class GeocodeResultDataModel {
  final double lat;
  final double lon;
  final String displayName;
  final String type;
  final double importance;

  const GeocodeResultDataModel({
    required this.lat,
    required this.lon,
    required this.displayName,
    required this.type,
    required this.importance,
  });

  factory GeocodeResultDataModel.fromJson(Map<String, dynamic> json) =>
      GeocodeResultDataModel(
        lat: (json['lat'] as num).toDouble(),
        lon: (json['lon'] as num).toDouble(),
        displayName: json['display_name'] as String? ?? '',
        type: json['type'] as String? ?? '',
        importance: (json['importance'] as num?)?.toDouble() ?? 0,
      );
}

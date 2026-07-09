/// Un registro de media de una propiedad (imagen o video).
/// Proviene de GET /properties/media/{id} y del detalle de propiedad.
class PropertyMedia {
  final String id;
  final String url;
  final String type;
  final String classification;

  const PropertyMedia({
    required this.id,
    required this.url,
    required this.type,
    required this.classification,
  });

  bool get isVideo => type.toUpperCase() == 'VIDEO';
  bool get isImage => !isVideo;

  factory PropertyMedia.fromJson(Map<String, dynamic> json) => PropertyMedia(
        id: json['id'] as String? ?? '',
        url: json['url'] as String? ?? '',
        type: json['type'] as String? ?? '',
        classification: json['classification'] as String? ?? '',
      );
}

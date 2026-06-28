class PropertySummaryModel {
  final String id;
  final String mainImageUrl;
  final String title;
  final double listedPrice;
  final double areaM2;
  final int bedrooms;
  final double bathrooms;
  final String propertyTypeName;

  const PropertySummaryModel({
    required this.id,
    required this.mainImageUrl,
    required this.title,
    required this.listedPrice,
    required this.areaM2,
    required this.bedrooms,
    required this.bathrooms,
    required this.propertyTypeName,
  });

  factory PropertySummaryModel.fromJson(Map<String, dynamic> json) =>
      PropertySummaryModel(
        id: json['id'] as String,
        mainImageUrl: json['mainImageUrl'] as String? ?? '',
        title: json['title'] as String? ?? '',
        listedPrice: (json['listedPrice'] as num).toDouble(),
        areaM2: (json['areaM2'] as num).toDouble(),
        bedrooms: (json['bedrooms'] as num).toInt(),
        bathrooms: (json['bathrooms'] as num).toDouble(),
        propertyTypeName: json['propertyTypeName'] as String? ?? '',
      );
}
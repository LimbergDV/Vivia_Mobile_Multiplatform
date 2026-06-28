class PropertyModel {
  final String id;
  final String title;
  final String type;
  final double price;
  final String location;
  final double area;
  final int bedrooms;
  final double bathrooms;
  final String imageUrl;
  final bool isFavorite;

  const PropertyModel({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.location,
    required this.area,
    required this.bedrooms,
    required this.bathrooms,
    required this.imageUrl,
    this.isFavorite = false,
  });
}
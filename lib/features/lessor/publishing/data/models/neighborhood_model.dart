class NeighborhoodModel {
  final String id;
  final String name;
  final String postalCode;

  const NeighborhoodModel({
    required this.id,
    required this.name,
    required this.postalCode,
  });

  factory NeighborhoodModel.fromJson(Map<String, dynamic> json) {
    return NeighborhoodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      postalCode: json['postalCode'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NeighborhoodModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

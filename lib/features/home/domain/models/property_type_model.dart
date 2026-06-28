class PropertyTypeModel {
  final String id;
  final String name;

  const PropertyTypeModel({required this.id, required this.name});

  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) =>
      PropertyTypeModel(
        id: json['id'] as String,
        name: json['name'] as String,
      );

  @override
  bool operator ==(Object other) =>
      other is PropertyTypeModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

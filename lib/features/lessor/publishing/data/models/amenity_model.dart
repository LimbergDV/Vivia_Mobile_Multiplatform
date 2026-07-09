class AmenityModel {
  final String id;
  final String name;

  const AmenityModel({required this.id, required this.name});

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(id: json['id'] as String, name: json['name'] as String);
  }
}

class UserProfileModel {
  final String? id;
  final String name;
  final String? photoUrl;

  const UserProfileModel({this.id, required this.name, this.photoUrl});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return UserProfileModel(
      id: data['id'] as String?,
      name: data['name'] as String,
      photoUrl: data['photoUrl'] as String?,
    );
  }
}

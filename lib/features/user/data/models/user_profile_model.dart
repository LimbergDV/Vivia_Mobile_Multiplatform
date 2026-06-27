class UserProfileModel {
  final String name;
  final String? photoUrl;

  const UserProfileModel({required this.name, this.photoUrl});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return UserProfileModel(
      name: data['name'] as String,
      photoUrl: data['photoUrl'] as String?,
    );
  }
}

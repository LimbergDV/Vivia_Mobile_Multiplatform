class PhotoPresignModel {
  final String presignedUrl;
  final String photoUrl;
  final int expiresInSeconds;

  const PhotoPresignModel({
    required this.presignedUrl,
    required this.photoUrl,
    required this.expiresInSeconds,
  });

  factory PhotoPresignModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PhotoPresignModel(
      presignedUrl: data['presignedUrl'] as String,
      photoUrl: data['photoUrl'] as String,
      expiresInSeconds: data['expiresInSeconds'] as int? ?? 300,
    );
  }
}

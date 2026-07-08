class VerificationUploadSlotModel {
  final String documentType;
  final String uploadUrl;
  final String publicUrl;

  const VerificationUploadSlotModel({
    required this.documentType,
    required this.uploadUrl,
    required this.publicUrl,
  });

  factory VerificationUploadSlotModel.fromJson(Map<String, dynamic> json) =>
      VerificationUploadSlotModel(
        documentType: json['documentType'] as String,
        uploadUrl: json['uploadUrl'] as String,
        publicUrl: json['publicUrl'] as String,
      );
}

class VerificationUploadModel {
  final List<VerificationUploadSlotModel> uploads;
  final int expiresInSeconds;

  const VerificationUploadModel({
    required this.uploads,
    required this.expiresInSeconds,
  });

  factory VerificationUploadModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return VerificationUploadModel(
      uploads: (data['uploads'] as List<dynamic>? ?? [])
          .map(
            (u) =>
                VerificationUploadSlotModel.fromJson(u as Map<String, dynamic>),
          )
          .toList(),
      expiresInSeconds: data['expiresInSeconds'] as int? ?? 300,
    );
  }
}

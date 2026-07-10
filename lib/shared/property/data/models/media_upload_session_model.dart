/// URL prefirmada de S3 para subir un archivo de la sesión.
class MediaUploadItem {
  final String fileKey;
  final String uploadUrl;
  final String storageKey;
  final int expiresInSeconds;

  const MediaUploadItem({
    required this.fileKey,
    required this.uploadUrl,
    required this.storageKey,
    required this.expiresInSeconds,
  });

  factory MediaUploadItem.fromJson(Map<String, dynamic> json) {
    return MediaUploadItem(
      fileKey: json['fileKey'] as String,
      uploadUrl: json['uploadUrl'] as String,
      storageKey: json['storageKey'] as String,
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Respuesta de POST /properties/media: sesión de subida con las URLs
/// prefirmadas de S3 (envelope BaseResponse → data).
class MediaUploadSessionModel {
  final String sessionId;
  final String propertyId;
  final String status;
  final List<MediaUploadItem> uploads;

  const MediaUploadSessionModel({
    required this.sessionId,
    required this.propertyId,
    required this.status,
    required this.uploads,
  });

  factory MediaUploadSessionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return MediaUploadSessionModel(
      sessionId: data['sessionId'] as String,
      propertyId: data['propertyId'] as String,
      status: data['status'] as String? ?? '',
      uploads: (data['uploads'] as List<dynamic>)
          .map((e) => MediaUploadItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

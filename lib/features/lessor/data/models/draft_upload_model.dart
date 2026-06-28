class DraftUploadItem {
  final String fileKey;
  final String uploadUrl;
  final String storageKey;

  const DraftUploadItem({
    required this.fileKey,
    required this.uploadUrl,
    required this.storageKey,
  });

  factory DraftUploadItem.fromJson(Map<String, dynamic> json) {
    return DraftUploadItem(
      fileKey: json['fileKey'] as String,
      uploadUrl: json['uploadUrl'] as String,
      storageKey: json['storageKey'] as String,
    );
  }
}

class DraftUploadModel {
  final String draftId;
  final String status;
  final List<DraftUploadItem> uploads;

  const DraftUploadModel({
    required this.draftId,
    required this.status,
    required this.uploads,
  });

  factory DraftUploadModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return DraftUploadModel(
      draftId: data['draftId'] as String,
      status: data['status'] as String,
      uploads: (data['uploads'] as List<dynamic>)
          .map((e) => DraftUploadItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

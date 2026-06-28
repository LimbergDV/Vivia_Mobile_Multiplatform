class MediaManifestItem {
  final String fileKey;
  final String contentType;
  final int sizeBytes;
  final String classification;

  const MediaManifestItem({
    required this.fileKey,
    required this.contentType,
    required this.sizeBytes,
    required this.classification,
  });

  Map<String, dynamic> toJson() => {
        'fileKey': fileKey,
        'contentType': contentType,
        'sizeBytes': sizeBytes,
        'classification': classification,
      };
}

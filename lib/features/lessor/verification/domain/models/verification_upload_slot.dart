class VerificationUploadSlot {
  final String documentType;
  final String uploadUrl;
  final String publicUrl;

  const VerificationUploadSlot({
    required this.documentType,
    required this.uploadUrl,
    required this.publicUrl,
  });
}

class VerificationUploadPlan {
  final List<VerificationUploadSlot> uploads;
  final int expiresInSeconds;

  const VerificationUploadPlan({
    required this.uploads,
    required this.expiresInSeconds,
  });
}

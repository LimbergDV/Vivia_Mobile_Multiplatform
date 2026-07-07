enum VerificationStatus {
  unverified,
  pendingReview,
  verified,
  rejected;

  static VerificationStatus fromApi(String value) => switch (value) {
        'VERIFIED' => VerificationStatus.verified,
        'PENDING_REVIEW' => VerificationStatus.pendingReview,
        'REJECTED' => VerificationStatus.rejected,
        _ => VerificationStatus.unverified,
      };
}

class VerificationRejectionModel {
  final String comment;
  final List<String> reasons;
  final String createdAt;

  const VerificationRejectionModel({
    required this.comment,
    required this.reasons,
    required this.createdAt,
  });

  factory VerificationRejectionModel.fromJson(Map<String, dynamic> json) =>
      VerificationRejectionModel(
        comment: json['comment'] as String? ?? '',
        reasons: (json['reasons'] as List<dynamic>? ?? [])
            .map((r) => r as String)
            .toList(),
        createdAt: json['createdAt'] as String? ?? '',
      );
}

class VerificationStatusModel {
  final String verificationStatus;
  final VerificationRejectionModel? rejection;

  const VerificationStatusModel({
    required this.verificationStatus,
    this.rejection,
  });

  factory VerificationStatusModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final rejection = data['rejection'];
    return VerificationStatusModel(
      verificationStatus: data['verificationStatus'] as String? ?? '',
      rejection: rejection is Map<String, dynamic>
          ? VerificationRejectionModel.fromJson(rejection)
          : null,
    );
  }
}

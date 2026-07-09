import 'package:vivia_mobile/features/user/domain/enums/verification_status.dart';

class VerificationRejection {
  final String comment;
  final List<String> reasons;
  final String createdAt;

  const VerificationRejection({
    required this.comment,
    required this.reasons,
    required this.createdAt,
  });
}

class LessorVerification {
  final VerificationStatus status;
  final VerificationRejection? rejection;

  const LessorVerification({required this.status, this.rejection});
}

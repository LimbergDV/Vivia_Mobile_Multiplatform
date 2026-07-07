import 'package:vivia_mobile/features/user/domain/enums/verification_status.dart';

class FullProfile {
  final String fullName;
  final String email;
  final String? photoUrl;
  final VerificationStatus status;

  const FullProfile({
    required this.fullName,
    required this.email,
    required this.status,
    this.photoUrl,
  });

  bool get isVerified => status == VerificationStatus.verified;
}

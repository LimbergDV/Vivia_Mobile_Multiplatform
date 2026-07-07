import 'package:vivia_mobile/features/user/domain/enums/verification_status.dart';

class FullProfile {
  final String name;
  final String paternalSurname;
  final String maternalSurname;
  final String email;
  final String? photoUrl;
  final VerificationStatus status;

  /// Solo lessor
  final String? phoneNumber;

  /// Solo lessee
  final double? latitude;
  final double? longitude;

  const FullProfile({
    required this.name,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.email,
    required this.status,
    this.photoUrl,
    this.phoneNumber,
    this.latitude,
    this.longitude,
  });

  String get fullName => [name, paternalSurname, maternalSurname]
      .where((part) => part.isNotEmpty)
      .join(' ');

  bool get isVerified => status == VerificationStatus.verified;
}

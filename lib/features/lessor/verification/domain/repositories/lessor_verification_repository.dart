import 'dart:typed_data';

import 'package:vivia_mobile/features/lessor/verification/domain/models/lessor_verification.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/models/verification_upload_slot.dart';

abstract class LessorVerificationRepository {
  Future<LessorVerification> getVerificationStatus();
  Future<VerificationUploadPlan> requestUploadUrls(
    List<({String documentType, String contentType})> documents,
  );
  Future<void> resetVerification();
  Future<void> uploadDocument({
    required VerificationUploadSlot slot,
    required Uint8List bytes,
    required String contentType,
  });
}

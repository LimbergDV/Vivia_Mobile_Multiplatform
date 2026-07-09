import 'dart:typed_data';

import 'package:vivia_mobile/features/lessor/verification/domain/models/verification_upload_slot.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/repositories/lessor_verification_repository.dart';

class UploadVerificationDocumentUseCase {
  final LessorVerificationRepository _repository;
  UploadVerificationDocumentUseCase(this._repository);

  Future<void> execute({
    required VerificationUploadSlot slot,
    required Uint8List bytes,
    required String contentType,
  }) => _repository.uploadDocument(
    slot: slot,
    bytes: bytes,
    contentType: contentType,
  );
}

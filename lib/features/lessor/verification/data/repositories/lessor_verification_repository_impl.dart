import 'dart:typed_data';

import 'package:vivia_mobile/features/lessor/verification/data/datasources/remote/lessor_verification_remote_datasource.dart';
import 'package:vivia_mobile/features/lessor/verification/data/models/verification_status_model.dart';
import 'package:vivia_mobile/features/lessor/verification/data/models/verification_upload_model.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/models/lessor_verification.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/models/verification_upload_slot.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/repositories/lessor_verification_repository.dart';
import 'package:vivia_mobile/features/user/domain/enums/verification_status.dart';

class LessorVerificationRepositoryImpl implements LessorVerificationRepository {
  final LessorVerificationRemoteDatasource _remote;

  LessorVerificationRepositoryImpl({
    required LessorVerificationRemoteDatasource remote,
  }) : _remote = remote;

  @override
  Future<LessorVerification> getVerificationStatus() async {
    final model = await _remote.getVerificationStatus();
    return _toDomain(model);
  }

  @override
  Future<VerificationUploadPlan> requestUploadUrls(
    List<({String documentType, String contentType})> documents,
  ) async {
    final model = await _remote.requestUploadUrls(documents);
    return VerificationUploadPlan(
      uploads: model.uploads.map(_toSlot).toList(),
      expiresInSeconds: model.expiresInSeconds,
    );
  }

  @override
  Future<void> resetVerification() => _remote.resetVerification();

  @override
  Future<void> uploadDocument({
    required VerificationUploadSlot slot,
    required Uint8List bytes,
    required String contentType,
  }) => _remote.uploadDocumentBytes(
    presignedUrl: slot.uploadUrl,
    bytes: bytes,
    contentType: contentType,
  );

  LessorVerification _toDomain(VerificationStatusModel m) => LessorVerification(
    status: VerificationStatus.fromApi(m.verificationStatus),
    rejection: m.rejection == null
        ? null
        : VerificationRejection(
            comment: m.rejection!.comment,
            reasons: m.rejection!.reasons,
            createdAt: m.rejection!.createdAt,
          ),
  );

  VerificationUploadSlot _toSlot(VerificationUploadSlotModel s) =>
      VerificationUploadSlot(
        documentType: s.documentType,
        uploadUrl: s.uploadUrl,
        publicUrl: s.publicUrl,
      );
}

import 'package:vivia_mobile/features/lessor/verification/domain/models/verification_upload_slot.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/repositories/lessor_verification_repository.dart';

class RequestVerificationUploadUrlsUseCase {
  final LessorVerificationRepository _repository;
  RequestVerificationUploadUrlsUseCase(this._repository);

  Future<VerificationUploadPlan> execute(
    List<({String documentType, String contentType})> documents,
  ) => _repository.requestUploadUrls(documents);
}

import 'package:vivia_mobile/features/lessor/verification/domain/models/lessor_verification.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/repositories/lessor_verification_repository.dart';

class GetVerificationStatusUseCase {
  final LessorVerificationRepository _repository;
  GetVerificationStatusUseCase(this._repository);

  Future<LessorVerification> execute() => _repository.getVerificationStatus();
}

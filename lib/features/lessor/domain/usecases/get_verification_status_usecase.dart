import 'package:vivia_mobile/features/lessor/domain/models/lessor_verification.dart';
import 'package:vivia_mobile/features/lessor/domain/repositories/lessor_verification_repository.dart';

class GetVerificationStatusUseCase {
  final LessorVerificationRepository _repository;
  GetVerificationStatusUseCase(this._repository);

  Future<LessorVerification> execute() => _repository.getVerificationStatus();
}

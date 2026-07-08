import 'package:vivia_mobile/features/lessor/domain/repositories/lessor_verification_repository.dart';

class ResetVerificationUseCase {
  final LessorVerificationRepository _repository;
  ResetVerificationUseCase(this._repository);

  Future<void> execute() => _repository.resetVerification();
}

import 'package:vivia_mobile/features/user/domain/repositories/user_repository.dart';

class UpdateEmailUseCase {
  final UserRepository _repository;
  UpdateEmailUseCase(this._repository);
  Future<void> execute(String email) => _repository.updateEmail(email);
}

import 'package:vivia_mobile/features/user/domain/repositories/user_repository.dart';

class UpdatePasswordUseCase {
  final UserRepository _repository;
  UpdatePasswordUseCase(this._repository);
  Future<void> execute(String password) =>
      _repository.updatePassword(password);
}

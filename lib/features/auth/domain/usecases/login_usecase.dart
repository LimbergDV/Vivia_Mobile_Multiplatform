import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<({String name, String role})> execute(
          String identifier, String password) =>
      _repository.login(identifier, password);
}

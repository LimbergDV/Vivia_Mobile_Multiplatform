import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';

class LoginGoogleUseCase {
  final AuthRepository _repository;

  LoginGoogleUseCase(this._repository);

  Future<void> execute(String idToken, UserRole role) =>
      _repository.loginWithGoogle(idToken, role);
}

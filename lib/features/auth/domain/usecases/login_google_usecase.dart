import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';

class LoginGoogleUseCase {
  final AuthRepository _repository;

  LoginGoogleUseCase(this._repository);

  Future<void> execute({
    required String idToken,
    required UserRole role,
    required String displayName,
    String? avatarUrl,
  }) =>
      _repository.loginWithGoogle(
        idToken: idToken,
        role: role,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
}

import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';

class RegisterLessorGoogleUseCase {
  final AuthRepository _repository;

  RegisterLessorGoogleUseCase(this._repository);

  Future<void> execute({
    required String idToken,
    required String displayName,
    String? avatarUrl,
  }) =>
      _repository.registerWithGoogle(
        idToken: idToken,
        role: UserRole.lessor,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
}

import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';

class RegisterLesseeGoogleUseCase {
  final AuthRepository _repository;

  RegisterLesseeGoogleUseCase(this._repository);

  Future<void> execute({
    required String idToken,
    required String displayName,
    String? avatarUrl,
  }) =>
      _repository.registerWithGoogle(
        idToken: idToken,
        role: UserRole.lessee,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
}

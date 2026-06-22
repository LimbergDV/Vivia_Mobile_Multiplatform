import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';

class RegisterLessorGoogleUseCase {
  final AuthRepository _repository;

  RegisterLessorGoogleUseCase(this._repository);

  Future<void> execute(String idToken) =>
      _repository.registerWithGoogle(idToken, UserRole.lessor);
}

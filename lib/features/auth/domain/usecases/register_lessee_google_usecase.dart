import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';

class RegisterLesseeGoogleUseCase {
  final AuthRepository _repository;

  RegisterLesseeGoogleUseCase(this._repository);

  Future<void> execute(String idToken) =>
      _repository.registerWithGoogle(idToken, UserRole.lessee);
}

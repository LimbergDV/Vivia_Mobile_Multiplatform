import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';

class RegisterLessorUseCase {
  final AuthRepository _repository;

  RegisterLessorUseCase(this._repository);

  Future<void> execute({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    required String email,
    required String phoneNumber,
    required String password,
  }) =>
      _repository.registerLessor(
        name: name,
        paternalSurname: paternalSurname,
        maternalSurname: maternalSurname,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
}

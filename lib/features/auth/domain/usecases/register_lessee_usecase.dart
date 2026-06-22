import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';

class RegisterLesseeUseCase {
  final AuthRepository _repository;

  RegisterLesseeUseCase(this._repository);

  Future<void> execute({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    required String email,
    required String password,
  }) =>
      _repository.registerLessee(
        name: name,
        paternalSurname: paternalSurname,
        maternalSurname: maternalSurname,
        email: email,
        password: password,
      );
}

import 'package:vivia_mobile/features/user/domain/repositories/user_repository.dart';

class UpdateNameUseCase {
  final UserRepository _repository;
  UpdateNameUseCase(this._repository);

  Future<void> execute({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
  }) =>
      _repository.updateName(
        name: name,
        paternalSurname: paternalSurname,
        maternalSurname: maternalSurname,
      );
}

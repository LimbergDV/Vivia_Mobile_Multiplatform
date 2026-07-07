import 'package:vivia_mobile/features/user/domain/repositories/user_repository.dart';

class UpdatePhoneUseCase {
  final UserRepository _repository;
  UpdatePhoneUseCase(this._repository);
  Future<void> execute(String phoneNumber) =>
      _repository.updatePhone(phoneNumber);
}

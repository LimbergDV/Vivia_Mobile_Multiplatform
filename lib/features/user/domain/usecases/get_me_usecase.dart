import 'package:vivia_mobile/features/user/data/models/user_profile_model.dart';
import 'package:vivia_mobile/features/user/domain/repositories/user_repository.dart';

class GetMeUseCase {
  final UserRepository _repository;
  GetMeUseCase(this._repository);

  Future<UserProfileModel> execute() => _repository.getMe();
}

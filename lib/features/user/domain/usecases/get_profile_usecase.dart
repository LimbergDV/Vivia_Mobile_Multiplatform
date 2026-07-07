import 'package:vivia_mobile/features/user/domain/models/full_profile.dart';
import 'package:vivia_mobile/features/user/domain/repositories/user_repository.dart';

class GetProfileUseCase {
  final UserRepository _repository;
  GetProfileUseCase(this._repository);
  Future<FullProfile> execute() => _repository.getProfile();
}

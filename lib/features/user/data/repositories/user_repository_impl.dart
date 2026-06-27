import 'package:vivia_mobile/features/user/data/datasources/remote/user_remote_datasource.dart';
import 'package:vivia_mobile/features/user/data/models/user_profile_model.dart';
import 'package:vivia_mobile/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource _remote;

  UserRepositoryImpl({required UserRemoteDatasource remote}) : _remote = remote;

  @override
  Future<void> updateFcmToken(String fcmToken) => _remote.updateFcmToken(fcmToken);

  @override
  Future<UserProfileModel> getMe() => _remote.getMe();
}

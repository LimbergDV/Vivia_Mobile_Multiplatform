import 'package:vivia_mobile/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:vivia_mobile/features/user/data/datasources/remote/user_remote_datasource.dart';
import 'package:vivia_mobile/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource _remote;
  final AuthLocalDatasource _local;

  UserRepositoryImpl({
    required UserRemoteDatasource remote,
    required AuthLocalDatasource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    final accessToken = _local.getAccessToken();
    if (accessToken == null) return;
    await _remote.updateFcmToken(fcmToken, accessToken);
  }
}

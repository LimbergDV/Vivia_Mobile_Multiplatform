import 'package:vivia_mobile/features/user/data/datasources/remote/user_remote_datasource.dart';
import 'package:vivia_mobile/features/user/data/models/full_profile_model.dart';
import 'package:vivia_mobile/features/user/data/models/user_profile_model.dart';
import 'package:vivia_mobile/features/user/domain/enums/verification_status.dart';
import 'package:vivia_mobile/features/user/domain/models/full_profile.dart';
import 'package:vivia_mobile/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource _remote;

  UserRepositoryImpl({required UserRemoteDatasource remote}) : _remote = remote;

  @override
  Future<void> updateFcmToken(String fcmToken) => _remote.updateFcmToken(fcmToken);

  @override
  Future<UserProfileModel> getMe() => _remote.getMe();

  @override
  Future<FullProfile> getProfile() async {
    final model = await _remote.getProfile();
    return _toModel(model);
  }

  FullProfile _toModel(FullProfileModel m) => FullProfile(
        fullName: [m.name, m.paternalSurname, m.maternalSurname]
            .where((part) => part.isNotEmpty)
            .join(' '),
        email: m.email,
        photoUrl: m.photoUrl,
        status: VerificationStatus.fromApi(m.verificationStatus),
      );
}

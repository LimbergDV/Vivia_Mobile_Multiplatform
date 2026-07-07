import 'dart:typed_data';

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

  @override
  Future<void> updateName({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
  }) =>
      _remote.updateName(
        name: name,
        paternalSurname: paternalSurname,
        maternalSurname: maternalSurname,
      );

  @override
  Future<void> updateEmail(String email) => _remote.updateEmail(email);

  @override
  Future<void> updatePhone(String phoneNumber) =>
      _remote.updatePhone(phoneNumber);

  @override
  Future<void> updatePassword(String password) =>
      _remote.updatePassword(password);

  @override
  Future<String> updateProfilePhoto({
    required Uint8List bytes,
    required String contentType,
  }) async {
    final presign = await _remote.getPhotoUploadUrl(contentType);
    await _remote.uploadPhotoBytes(
      presignedUrl: presign.presignedUrl,
      bytes: bytes,
      contentType: contentType,
    );
    return presign.photoUrl;
  }

  FullProfile _toModel(FullProfileModel m) => FullProfile(
        name: m.name,
        paternalSurname: m.paternalSurname,
        maternalSurname: m.maternalSurname,
        email: m.email,
        photoUrl: m.photoUrl,
        status: VerificationStatus.fromApi(m.verificationStatus),
        phoneNumber: m.phoneNumber,
        latitude: m.latitude,
        longitude: m.longitude,
      );
}

import 'dart:typed_data';

import 'package:vivia_mobile/features/user/data/models/user_profile_model.dart';
import 'package:vivia_mobile/features/user/domain/models/full_profile.dart';

abstract class UserRepository {
  Future<void> updateFcmToken(String fcmToken);
  Future<UserProfileModel> getMe();
  Future<FullProfile> getProfile();
  Future<void> updateName({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
  });
  Future<void> updateEmail(String email);
  Future<void> updatePhone(String phoneNumber);
  Future<void> updatePassword(String password);

  /// Sube la foto (presign + PUT a S3) y retorna la URL pública final.
  Future<String> updateProfilePhoto({
    required Uint8List bytes,
    required String contentType,
  });
}

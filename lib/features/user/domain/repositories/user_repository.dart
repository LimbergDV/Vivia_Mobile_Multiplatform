import 'package:vivia_mobile/features/user/data/models/user_profile_model.dart';
import 'package:vivia_mobile/features/user/domain/models/full_profile.dart';

abstract class UserRepository {
  Future<void> updateFcmToken(String fcmToken);
  Future<UserProfileModel> getMe();
  Future<FullProfile> getProfile();
}

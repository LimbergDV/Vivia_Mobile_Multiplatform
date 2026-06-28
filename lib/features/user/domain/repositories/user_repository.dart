import 'package:vivia_mobile/features/user/data/models/user_profile_model.dart';

abstract class UserRepository {
  Future<void> updateFcmToken(String fcmToken);
  Future<UserProfileModel> getMe();
}

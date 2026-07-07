import 'package:vivia_mobile/features/auth/data/datasources/remote/constants/auth_api_constants.dart';

class UserApiConstants {
  UserApiConstants._();

  static String get baseUrl => AuthApiConstants.baseUrl;

  static String get me => '$baseUrl/users/me';
  static String get profile => '$baseUrl/users/profile';
  static String get fcmToken => '$baseUrl/users/me/fcm-token';
  static String get updateName => '$baseUrl/users/me/name';
  static String get updateEmail => '$baseUrl/users/me/email';
  static String get updatePhone => '$baseUrl/users/me/phone';
  static String get updatePassword => '$baseUrl/auth/me/password';
  static String get photoPresign => '$baseUrl/users/me/photo';

  static Map<String, String> headers() => AuthApiConstants.headers();
}

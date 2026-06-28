import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vivia_mobile/features/auth/data/datasources/remote/constants/auth_api_constants.dart';

class UserApiConstants {
  UserApiConstants._();

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static String get me => '$baseUrl/users/me';
  static String get fcmToken => '$baseUrl/users/me/fcm-token';

  static Map<String, String> headers() => AuthApiConstants.headers();
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vivia_mobile/features/auth/data/datasources/remote/constants/auth_api_constants.dart';

class PropertyApiConstants {
  PropertyApiConstants._();

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static String get types => '$baseUrl/properties/types';
  static String get propertiesMe => '$baseUrl/properties/me';
  static String get propertiesMeLikes => '$baseUrl/properties/me/likes';

  static Map<String, String> headers() => AuthApiConstants.headers();
}

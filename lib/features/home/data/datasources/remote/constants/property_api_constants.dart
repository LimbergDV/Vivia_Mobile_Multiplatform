import 'package:vivia_mobile/features/auth/data/datasources/remote/constants/auth_api_constants.dart';

class PropertyApiConstants {
  PropertyApiConstants._();

  static String get baseUrl => AuthApiConstants.baseUrl;

  static String get types => '$baseUrl/properties/types';
  static String get propertiesMe => '$baseUrl/properties/me';
  static String get propertiesMeLikes => '$baseUrl/properties/me/likes';
  static String propertyDetail(String id) => '$baseUrl/properties/$id';
  static String propertyMedia(String id) => '$baseUrl/properties/media/$id';
  static String get propertiesSuggestions => '$baseUrl/properties/suggestions';

  static Map<String, String> headers() => AuthApiConstants.headers();
}
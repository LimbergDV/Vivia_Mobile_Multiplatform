import 'package:vivia_mobile/features/auth/data/datasources/remote/constants/auth_api_constants.dart';

class LessorApiConstants {
  LessorApiConstants._();

  static String get baseUrl => AuthApiConstants.baseUrl;

  static String neighborhoodsByPostalCode(String cp) =>
      '$baseUrl/neighborhoods/$cp';

  static String get amenities => '$baseUrl/amenities';

  static String get propertiesDraft => '$baseUrl/properties/draft';

  static Map<String, String> headers() => AuthApiConstants.headers();
}

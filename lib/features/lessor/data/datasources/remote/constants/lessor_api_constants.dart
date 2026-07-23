import 'package:vivia_mobile/features/auth/data/datasources/remote/constants/auth_api_constants.dart';

class LessorApiConstants {
  LessorApiConstants._();

  static String get baseUrl => AuthApiConstants.baseUrl;

  static String neighborhoodsByPostalCode(String cp) =>
      '$baseUrl/neighborhoods/$cp';

  static String get amenities => '$baseUrl/amenities';

  static String get verifications => '$baseUrl/lessors/verifications';
  static String get verificationUploadUrls =>
      '$baseUrl/lessors/verifications/upload-urls';

  static String get propertiesPosts => '$baseUrl/properties/posts';
  static String get propertiesDraft => '$baseUrl/properties/draft';
  static String draftStatusStream(String draftId) =>
      '$baseUrl/properties/draft/$draftId/status/stream';

  static String get llmContentGenerations =>
      '$baseUrl/llm/contents/generations';

  static Map<String, String> headers() => AuthApiConstants.headers();
}

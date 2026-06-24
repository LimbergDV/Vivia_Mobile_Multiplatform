import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthApiConstants {
  AuthApiConstants._();

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  // ── Auth ──────────────────────────────────────────────────────────────
  static String get login => '$baseUrl/auth/login';
  static String get loginGoogle => '$baseUrl/auth/login/google';
  static String get loginChallenge => '$baseUrl/auth/login/challenge';
  static String get loginVerify => '$baseUrl/auth/login/verify';
  static String get refresh => '$baseUrl/auth/refresh';
  static String get logout => '$baseUrl/auth/logout';

  // ── Lessee ────────────────────────────────────────────────────────────
  static String get registerLessee => '$baseUrl/lessees/password';
  static String get registerLesseeGoogle => '$baseUrl/lessees/google';
  static String get lesseeBiometricChallenge =>
      '$baseUrl/lessees/biometric/challenge';
  static String get lesseeBiometricVerify =>
      '$baseUrl/lessees/biometric/verify';

  // ── Lessor ────────────────────────────────────────────────────────────
  static String get registerLessor => '$baseUrl/lessors/password';
  static String get registerLessorGoogle => '$baseUrl/lessors/google';
  static String get lessorBiometricChallenge =>
      '$baseUrl/lessors/biometric/challenge';
  static String get lessorBiometricVerify =>
      '$baseUrl/lessors/biometric/verify';

  // ── Headers ───────────────────────────────────────────────────────────
  static Map<String, String> headers({String? accessToken}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };
}

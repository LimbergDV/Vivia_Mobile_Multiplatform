class AuthApiConstants {
  AuthApiConstants._();

  // ── Base ──────────────────────────────────────────────────────────────
  // TODO: Reemplazar con la URL real de tu servidor AWS
  static const String baseUrl = 'https://TU_URL_AWS.com';

  // ── Auth ──────────────────────────────────────────────────────────────
  static const String login = '$baseUrl/auth/login';
  static const String loginGoogle = '$baseUrl/auth/login/google';
  static const String loginChallenge = '$baseUrl/auth/login/challenge';
  static const String loginVerify = '$baseUrl/auth/login/verify';
  static const String refresh = '$baseUrl/auth/refresh';
  static const String logout = '$baseUrl/auth/logout';

  // ── Lessee ────────────────────────────────────────────────────────────
  static const String registerLessee = '$baseUrl/lessees/password';
  static const String registerLesseeGoogle = '$baseUrl/lessees/google';
  static const String lesseeBiometricChallenge =
      '$baseUrl/lessees/biometric/challenge';
  static const String lesseeBiometricVerify =
      '$baseUrl/lessees/biometric/verify';

  // ── Lessor ────────────────────────────────────────────────────────────
  static const String registerLessor = '$baseUrl/lessors/password';
  static const String registerLessorGoogle = '$baseUrl/lessors/google';
  static const String lessorBiometricChallenge =
      '$baseUrl/lessors/biometric/challenge';
  static const String lessorBiometricVerify =
      '$baseUrl/lessors/biometric/verify';

  // ── Headers ───────────────────────────────────────────────────────────
  static Map<String, String> headers({String? accessToken}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };
}

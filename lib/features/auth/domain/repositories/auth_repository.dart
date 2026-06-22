import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';

abstract class AuthRepository {
  // Password
  Future<void> login(String identifier, String password);
  Future<void> registerLessee({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    required String email,
    required String password,
  });
  Future<void> registerLessor({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    required String email,
    required String phoneNumber,
    required String password,
  });

  // Google
  Future<void> loginWithGoogle(String idToken, UserRole role);
  Future<void> registerWithGoogle(String idToken, UserRole role);

  // Biométrico
  Future<String> requestLoginChallenge(String email);
  Future<void> verifyLoginChallenge(String credentialResponseJson);
  Future<String> requestRegisterChallenge({
    required UserRole role,
    required String email,
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    String? phoneNumber,
  });
  Future<void> verifyRegisterChallenge(
      String credentialResponseJson, UserRole role);

  // Sesión
  Future<void> logout();
  bool get isLoggedIn;
  String? get savedRole;
}

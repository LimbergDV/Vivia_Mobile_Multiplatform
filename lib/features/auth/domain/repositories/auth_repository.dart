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
  Future<void> loginWithGoogle({
    required String idToken,
    required UserRole role,
    required String displayName,
    String? avatarUrl,
  });
  Future<void> registerWithGoogle({
    required String idToken,
    required UserRole role,
    required String displayName,
    String? avatarUrl,
  });

  // Sesión
  Future<void> logout();
  bool get isLoggedIn;
  String? get savedRole;
  String? get savedUserName;
  String? get savedAvatarUrl;
}

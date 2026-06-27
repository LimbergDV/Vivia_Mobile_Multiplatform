import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';

abstract class AuthRepository {
  /// Retorna ({name, role}) extraídos del JWT tras login exitoso.
  Future<({String name, String role})> login(String identifier, String password);

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

  Future<void> logout();
  bool get isLoggedIn;
  String? get savedRole;
  String? get savedUserName;
  String? get savedAvatarUrl;

  bool get hasSeenLocationPermission;
  Future<void> setLocationPermissionShown();
  Future<void> putUbication({required double latitude, required double longitude});
}

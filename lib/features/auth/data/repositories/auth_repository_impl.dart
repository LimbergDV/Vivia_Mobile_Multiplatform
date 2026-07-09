import 'package:vivia_mobile/core/utils/jwt_utils.dart';
import 'package:vivia_mobile/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:vivia_mobile/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final AuthLocalDatasource _local;

  AuthRepositoryImpl({
    required AuthRemoteDatasource remote,
    required AuthLocalDatasource local,
  })  : _remote = remote,
        _local = local;

  // ── Helpers ───────────────────────────────────────────────────────────

  String _extractRoleFromClaims(Map<String, dynamic> claims) {
    return claims['role'] as String? ?? 'ROLE_LESSEE';
  }

  String _extractFirstNameFromClaims(Map<String, dynamic> claims) {
    final candidates = [
      'name', 'given_name', 'firstName', 'first_name',
      'nombre', 'display_name', 'displayName', 'fullName',
    ];
    for (final key in candidates) {
      final val = claims[key] as String?;
      if (val != null && val.isNotEmpty) {
        return val.split(' ').first;
      }
    }
    return '';
  }

  // ── Password ──────────────────────────────────────────────────────────

  @override
  Future<({String name, String role})> login(
      String identifier, String password) async {
    final result = await _remote.login(identifier, password);
    final claims = JwtUtils.decodePayload(result.accessToken);
    final role = _extractRoleFromClaims(claims);
    final firstName = _extractFirstNameFromClaims(claims);
    final name = firstName.isNotEmpty ? firstName : identifier.split('@').first;

    await _local.saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      role: role,
      userName: name,
    );
    return (name: name, role: role);
  }

  @override
  Future<void> registerLessee({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    required String email,
    required String password,
  }) async {
    final result = await _remote.registerLessee(
      name: name,
      paternalSurname: paternalSurname,
      maternalSurname: maternalSurname,
      email: email,
      password: password,
    );
    await _local.saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      role: 'ROLE_LESSEE',
      userName: name,
    );
  }

  @override
  Future<void> registerLessor({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final result = await _remote.registerLessor(
      name: name,
      paternalSurname: paternalSurname,
      maternalSurname: maternalSurname,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
    await _local.saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      role: 'ROLE_LESSOR',
      userName: name,
    );
  }

  // ── Google ────────────────────────────────────────────────────────────

  @override
  Future<void> loginWithGoogle({
    required String idToken,
    required UserRole role,
    required String displayName,
    String? avatarUrl,
  }) async {
    final roleStr = role == UserRole.lessee ? 'ROLE_LESSEE' : 'ROLE_LESSOR';
    final result = await _remote.loginWithGoogle(idToken, roleStr);
    final claims = JwtUtils.decodePayload(result.accessToken);
    final actualRole = _extractRoleFromClaims(claims);
    await _local.saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      role: actualRole,
      userName: displayName.split(' ').first,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<void> registerWithGoogle({
    required String idToken,
    required UserRole role,
    required String displayName,
    String? avatarUrl,
  }) async {
    final result = role == UserRole.lessee
        ? await _remote.registerLesseeWithGoogle(idToken)
        : await _remote.registerLessorWithGoogle(idToken);
    await _local.saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      role: role == UserRole.lessee ? 'ROLE_LESSEE' : 'ROLE_LESSOR',
      userName: displayName.split(' ').first,
      avatarUrl: avatarUrl,
    );
  }

  // ── Sesión ────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (_) {}
    await _local.clearSession();
  }

  @override
  bool get isLoggedIn => _local.isLoggedIn;

  @override
  String? get savedRole => _local.getRole();

  @override
  String? get savedUserName => _local.getUserName();

  @override
  String? get savedAvatarUrl => _local.getAvatarUrl();

  @override
  String? get savedUserId {
    final token = _local.getAccessToken();
    if (token == null) return null;
    final claims = JwtUtils.decodePayload(token);
    return claims['sub']?.toString() ??
        claims['userId']?.toString() ??
        claims['id']?.toString();
  }

  // ── Ubicación ─────────────────────────────────────────────────────────

  @override
  bool get hasSeenLocationPermission => _local.getLocationPermissionShown();

  @override
  Future<void> setLocationPermissionShown() =>
      _local.setLocationPermissionShown();

  @override
  Future<void> putUbication({
    required double latitude,
    required double longitude,
  }) =>
      _remote.putUbication(latitude: latitude, longitude: longitude);
}

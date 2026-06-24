import 'dart:convert';

import 'package:vivia_mobile/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:vivia_mobile/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:vivia_mobile/features/auth/data/models/auth_response_model.dart';
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

  String _extractRoleFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 'ROLE_LESSEE';
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final json = jsonDecode(payload) as Map<String, dynamic>;
      return json['role'] as String? ?? 'ROLE_LESSEE';
    } catch (_) {
      return 'ROLE_LESSEE';
    }
  }

  String _extractNameFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final json = jsonDecode(payload) as Map<String, dynamic>;
      return json['name'] as String? ??
          json['sub'] as String? ??
          '';
    } catch (_) {
      return '';
    }
  }

  // ── Password ──────────────────────────────────────────────────────────

  @override
  Future<void> login(String identifier, String password) async {
    final result = await _remote.login(identifier, password);
    final role = _extractRoleFromJwt(result.accessToken);
    final name = _extractNameFromJwt(result.accessToken);
    await _local.saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      role: role,
      userName: name.isNotEmpty ? name : identifier.split('@').first,
    );
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
      userName: '$name $paternalSurname',
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
      userName: '$name $paternalSurname',
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
    await _local.saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      role: roleStr,
      userName: displayName,
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
      userName: displayName,
      avatarUrl: avatarUrl,
    );
  }

  // ── Sesión ────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    final token = _local.getAccessToken();
    if (token != null) {
      try {
        await _remote.logout(token);
      } catch (_) {}
    }
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
}

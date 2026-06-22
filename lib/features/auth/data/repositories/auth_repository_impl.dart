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

  Future<void> _saveFromResponse(AuthResponseModel model, UserRole role) async {
    final roleStr = role == UserRole.lessee ? 'ROLE_LESSEE' : 'ROLE_LESSOR';
    await _local.saveSession(
      accessToken: model.accessToken,
      refreshToken: model.refreshToken,
      role: roleStr,
    );
  }

  /// Decodifica el payload del JWT (sin validar firma) para leer el claim "role".
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

  // ── Password ──────────────────────────────────────────────────────────

  @override
  Future<void> login(String identifier, String password) async {
    final result = await _remote.login(identifier, password);
    final role = _extractRoleFromJwt(result.accessToken);
    await _local.saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      role: role,
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
    );
  }

  // ── Google ────────────────────────────────────────────────────────────

  @override
  Future<void> loginWithGoogle(String idToken, UserRole role) async {
    final roleStr = role == UserRole.lessee ? 'ROLE_LESSEE' : 'ROLE_LESSOR';
    final result = await _remote.loginWithGoogle(idToken, roleStr);
    await _local.saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      role: roleStr,
    );
  }

  @override
  Future<void> registerWithGoogle(String idToken, UserRole role) async {
    final result = role == UserRole.lessee
        ? await _remote.registerLesseeWithGoogle(idToken)
        : await _remote.registerLessorWithGoogle(idToken);
    await _local.saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      role: role == UserRole.lessee ? 'ROLE_LESSEE' : 'ROLE_LESSOR',
    );
  }

  // ── Biométrico ────────────────────────────────────────────────────────

  @override
  Future<String> requestLoginChallenge(String email) =>
      _remote.requestLoginChallenge(email);

  @override
  Future<void> verifyLoginChallenge(String credentialResponseJson) async {
    final result = await _remote.verifyLoginChallenge(credentialResponseJson);
    final role = _extractRoleFromJwt(result.accessToken);
    await _local.saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      role: role,
    );
  }

  @override
  Future<String> requestRegisterChallenge({
    required UserRole role,
    required String email,
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    String? phoneNumber,
  }) {
    if (role == UserRole.lessee) {
      return _remote.requestLesseeBiometricChallenge(
        email: email,
        name: name,
        paternalSurname: paternalSurname,
        maternalSurname: maternalSurname,
      );
    } else {
      return _remote.requestLessorBiometricChallenge(
        email: email,
        name: name,
        paternalSurname: paternalSurname,
        maternalSurname: maternalSurname,
        phoneNumber: phoneNumber ?? '',
      );
    }
  }

  @override
  Future<void> verifyRegisterChallenge(
      String credentialResponseJson, UserRole role) async {
    final result = role == UserRole.lessee
        ? await _remote.verifyLesseeBiometricChallenge(credentialResponseJson)
        : await _remote.verifyLessorBiometricChallenge(credentialResponseJson);
    await _local.saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      role: role == UserRole.lessee ? 'ROLE_LESSEE' : 'ROLE_LESSOR',
    );
  }

  // ── Sesión ────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    final token = _local.getAccessToken();
    if (token != null) {
      try {
        await _remote.logout(token);
      } catch (_) {
        // Silenciar error de red en logout; la sesión local se limpia igual
      }
    }
    await _local.clearSession();
  }

  @override
  bool get isLoggedIn => _local.isLoggedIn;

  @override
  String? get savedRole => _local.getRole();
}

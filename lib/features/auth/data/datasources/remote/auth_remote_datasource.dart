import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:vivia_mobile/features/auth/data/datasources/remote/constants/auth_api_constants.dart';
import 'package:vivia_mobile/features/auth/data/models/auth_response_model.dart';

// ── Contrato ──────────────────────────────────────────────────────────────
abstract class AuthRemoteDatasource {
  // Password
  Future<AuthResponseModel> login(String identifier, String password);
  Future<AuthResponseModel> registerLessee({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    required String email,
    required String password,
  });
  Future<AuthResponseModel> registerLessor({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    required String email,
    required String phoneNumber,
    required String password,
  });

  // Google
  Future<AuthResponseModel> loginWithGoogle(String idToken, String role);
  Future<AuthResponseModel> registerLesseeWithGoogle(String idToken);
  Future<AuthResponseModel> registerLessorWithGoogle(String idToken);

  // Biométrico (WebAuthn)
  Future<String> requestLoginChallenge(String email);
  Future<AuthResponseModel> verifyLoginChallenge(String credentialResponseJson);
  Future<String> requestLesseeBiometricChallenge({
    required String email,
    required String name,
    required String paternalSurname,
    required String maternalSurname,
  });
  Future<AuthResponseModel> verifyLesseeBiometricChallenge(
      String credentialResponseJson);
  Future<String> requestLessorBiometricChallenge({
    required String email,
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    required String phoneNumber,
  });
  Future<AuthResponseModel> verifyLessorBiometricChallenge(
      String credentialResponseJson);

  // Sesión
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<void> logout();

  // Ubicación
  Future<void> putUbication({
    required double latitude,
    required double longitude,
  });
}

// ── Implementación ────────────────────────────────────────────────────────
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  AuthRemoteDatasourceImpl(this._client);

  // ── Helpers de parseo ─────────────────────────────────────────────────

  /// Parsea respuestas exitosas 200/201 con `{ success: true, data: {...} }`.
  /// Para errores lanza [Exception] con el `message` del backend.
  AuthResponseModel _parseSuccess(http.Response response) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        json['success'] == true) {
      return AuthResponseModel.fromJson(json);
    }
    throw Exception(json['message'] ?? 'Error ${response.statusCode}');
  }

  /// Parsea la respuesta de challenge (data es un String JSON).
  String _parseChallengeSuccess(http.Response response) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && json['success'] == true) {
      return json['data'] as String;
    }
    throw Exception(json['message'] ?? 'Error al obtener challenge');
  }

  // ── Password ──────────────────────────────────────────────────────────

  @override
  Future<AuthResponseModel> login(String identifier, String password) async {
    final res = await _client.post(
      Uri.parse(AuthApiConstants.login),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({'identifier': identifier, 'password': password}),
    ).timeout(_timeout);
    return _parseSuccess(res);
  }

  @override
  Future<AuthResponseModel> registerLessee({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    required String email,
    required String password,
  }) async {
    final res = await _client.post(
      Uri.parse(AuthApiConstants.registerLessee),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({
        'name': name,
        'paternalSurname': paternalSurname,
        'maternalSurname': maternalSurname,
        'email': email,
        'password': password,
      }),
    ).timeout(_timeout);
    return _parseSuccess(res);
  }

  @override
  Future<AuthResponseModel> registerLessor({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final res = await _client.post(
      Uri.parse(AuthApiConstants.registerLessor),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({
        'name': name,
        'paternalSurname': paternalSurname,
        'maternalSurname': maternalSurname,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
      }),
    ).timeout(_timeout);
    return _parseSuccess(res);
  }

  // ── Google ────────────────────────────────────────────────────────────

  @override
  Future<AuthResponseModel> loginWithGoogle(
      String idToken, String role) async {
    final res = await _client.post(
      Uri.parse(AuthApiConstants.loginGoogle),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({'idToken': idToken, 'role': role}),
    ).timeout(_timeout);
    return _parseSuccess(res);
  }

  @override
  Future<AuthResponseModel> registerLesseeWithGoogle(String idToken) async {
    final res = await _client.post(
      Uri.parse(AuthApiConstants.registerLesseeGoogle),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({'idToken': idToken}),
    ).timeout(_timeout);
    return _parseSuccess(res);
  }

  @override
  Future<AuthResponseModel> registerLessorWithGoogle(String idToken) async {
    final res = await _client.post(
      Uri.parse(AuthApiConstants.registerLessorGoogle),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({'idToken': idToken}),
    ).timeout(_timeout);
    return _parseSuccess(res);
  }

  // ── Biométrico (WebAuthn) ─────────────────────────────────────────────

  @override
  Future<String> requestLoginChallenge(String email) async {
    final res = await _client.post(
      Uri.parse(AuthApiConstants.loginChallenge),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({'email': email}),
    ).timeout(_timeout);
    return _parseChallengeSuccess(res);
  }

  @override
  Future<AuthResponseModel> verifyLoginChallenge(
      String credentialResponseJson) async {
    final res = await _client.post(
      Uri.parse(AuthApiConstants.loginVerify),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({'credentialResponseJson': credentialResponseJson}),
    ).timeout(_timeout);
    return _parseSuccess(res);
  }

  @override
  Future<String> requestLesseeBiometricChallenge({
    required String email,
    required String name,
    required String paternalSurname,
    required String maternalSurname,
  }) async {
    final res = await _client.post(
      Uri.parse(AuthApiConstants.lesseeBiometricChallenge),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({
        'email': email,
        'name': name,
        'paternalSurname': paternalSurname,
        'maternalSurname': maternalSurname,
      }),
    ).timeout(_timeout);
    return _parseChallengeSuccess(res);
  }

  @override
  Future<AuthResponseModel> verifyLesseeBiometricChallenge(
      String credentialResponseJson) async {
    final res = await _client.post(
      Uri.parse(AuthApiConstants.lesseeBiometricVerify),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({'credentialResponseJson': credentialResponseJson}),
    ).timeout(_timeout);
    return _parseSuccess(res);
  }

  @override
  Future<String> requestLessorBiometricChallenge({
    required String email,
    required String name,
    required String paternalSurname,
    required String maternalSurname,
    required String phoneNumber,
  }) async {
    final res = await _client.post(
      Uri.parse(AuthApiConstants.lessorBiometricChallenge),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({
        'email': email,
        'name': name,
        'paternalSurname': paternalSurname,
        'maternalSurname': maternalSurname,
        'phoneNumber': phoneNumber,
      }),
    ).timeout(_timeout);
    return _parseChallengeSuccess(res);
  }

  @override
  Future<AuthResponseModel> verifyLessorBiometricChallenge(
      String credentialResponseJson) async {
    final res = await _client.post(
      Uri.parse(AuthApiConstants.lessorBiometricVerify),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({'credentialResponseJson': credentialResponseJson}),
    ).timeout(_timeout);
    return _parseSuccess(res);
  }

  // ── Sesión ────────────────────────────────────────────────────────────

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final res = await _client.post(
      Uri.parse(AuthApiConstants.refresh),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({'refreshToken': refreshToken}),
    ).timeout(_timeout);
    return _parseSuccess(res);
  }

  @override
  Future<void> logout() async {
    await _client.post(
      Uri.parse(AuthApiConstants.logout),
      headers: AuthApiConstants.headers(),
    ).timeout(_timeout);
  }

  // ── Ubicación ─────────────────────────────────────────────────────────

  @override
  Future<void> putUbication({
    required double latitude,
    required double longitude,
  }) async {
    await _client.put(
      Uri.parse(AuthApiConstants.lesseeUbication),
      headers: AuthApiConstants.headers(),
      body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
    ).timeout(_timeout);
  }
}

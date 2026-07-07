import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:vivia_mobile/features/user/data/datasources/remote/constants/user_api_constants.dart';
import 'package:vivia_mobile/features/user/data/models/full_profile_model.dart';
import 'package:vivia_mobile/features/user/data/models/photo_presign_model.dart';
import 'package:vivia_mobile/features/user/data/models/user_profile_model.dart';

// ── Contrato ──────────────────────────────────────────────────────────────────
abstract class UserRemoteDatasource {
  Future<void> updateFcmToken(String fcmToken);
  Future<UserProfileModel> getMe();
  Future<FullProfileModel> getProfile();
  Future<void> updateName({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
  });
  Future<void> updateEmail(String email);
  Future<void> updatePhone(String phoneNumber);
  Future<void> updatePassword(String password);
  Future<PhotoPresignModel> getPhotoUploadUrl(String contentType);
  Future<void> uploadPhotoBytes({
    required String presignedUrl,
    required Uint8List bytes,
    required String contentType,
  });
}

// ── Implementación ────────────────────────────────────────────────────────────
class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final http.Client _client;

  /// Cliente sin interceptor JWT — la presigned URL de S3 rechaza el header
  /// Authorization.
  final http.Client _plainClient;
  static const _timeout = Duration(seconds: 15);

  UserRemoteDatasourceImpl(this._client, this._plainClient);

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    final res = await _client.put(
      Uri.parse(UserApiConstants.fcmToken),
      headers: UserApiConstants.headers(),
      body: jsonEncode({'fcmToken': fcmToken}),
    ).timeout(_timeout);

    if (res.statusCode != 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(json['message'] ?? 'Error al registrar FCM token');
    }
  }

  @override
  Future<UserProfileModel> getMe() async {
    final res = await _client.get(
      Uri.parse(UserApiConstants.me),
      headers: UserApiConstants.headers(),
    ).timeout(_timeout);

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && json['success'] == true) {
      return UserProfileModel.fromJson(json);
    }
    throw Exception(json['message'] ?? 'Error al obtener perfil');
  }

  @override
  Future<FullProfileModel> getProfile() async {
    final res = await _client.get(
      Uri.parse(UserApiConstants.profile),
      headers: UserApiConstants.headers(),
    ).timeout(_timeout);

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && json['success'] == true) {
      return FullProfileModel.fromJson(json);
    }
    throw Exception(json['message'] ?? 'Error al obtener perfil completo');
  }

  @override
  Future<void> updateName({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
  }) =>
      _patchVoid(UserApiConstants.updateName, {
        'name': name,
        'paternalSurname': paternalSurname,
        'maternalSurname': maternalSurname,
      }, 'Error al actualizar nombre');

  @override
  Future<void> updateEmail(String email) => _patchVoid(
      UserApiConstants.updateEmail, {'email': email}, 'Error al actualizar correo');

  @override
  Future<void> updatePhone(String phoneNumber) => _patchVoid(
      UserApiConstants.updatePhone,
      {'phoneNumber': phoneNumber},
      'Error al actualizar teléfono');

  @override
  Future<void> updatePassword(String password) => _patchVoid(
      UserApiConstants.updatePassword,
      {'password': password},
      'Error al actualizar contraseña');

  @override
  Future<PhotoPresignModel> getPhotoUploadUrl(String contentType) async {
    final res = await _client.put(
      Uri.parse(UserApiConstants.photoPresign),
      headers: UserApiConstants.headers(),
      body: jsonEncode({'contentType': contentType}),
    ).timeout(_timeout);

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && json['success'] == true) {
      return PhotoPresignModel.fromJson(json);
    }
    throw Exception(json['message'] ?? 'Error al generar URL de foto');
  }

  @override
  Future<void> uploadPhotoBytes({
    required String presignedUrl,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final res = await _plainClient
        .put(
          Uri.parse(presignedUrl),
          headers: {'Content-Type': contentType},
          body: bytes,
        )
        .timeout(const Duration(seconds: 60));

    if (res.statusCode != 200) {
      throw Exception('Error al subir la foto de perfil');
    }
  }

  Future<void> _patchVoid(
    String url,
    Map<String, dynamic> body,
    String defaultError,
  ) async {
    final res = await _client.patch(
      Uri.parse(url),
      headers: UserApiConstants.headers(),
      body: jsonEncode(body),
    ).timeout(_timeout);

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || json['success'] != true) {
      throw Exception(json['message'] ?? defaultError);
    }
  }
}

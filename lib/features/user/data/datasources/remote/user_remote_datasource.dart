import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:vivia_mobile/features/user/data/datasources/remote/constants/user_api_constants.dart';
import 'package:vivia_mobile/features/user/data/models/full_profile_model.dart';
import 'package:vivia_mobile/features/user/data/models/user_profile_model.dart';

// ── Contrato ──────────────────────────────────────────────────────────────────
abstract class UserRemoteDatasource {
  Future<void> updateFcmToken(String fcmToken);
  Future<UserProfileModel> getMe();
  Future<FullProfileModel> getProfile();
}

// ── Implementación ────────────────────────────────────────────────────────────
class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  UserRemoteDatasourceImpl(this._client);

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
}

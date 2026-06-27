import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:vivia_mobile/features/user/data/datasources/remote/constants/user_api_constants.dart';

// ── Contrato ──────────────────────────────────────────────────────────────────
abstract class UserRemoteDatasource {
  Future<void> updateFcmToken(String fcmToken, String accessToken);
}

// ── Implementación ────────────────────────────────────────────────────────────
class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  UserRemoteDatasourceImpl(this._client);

  @override
  Future<void> updateFcmToken(String fcmToken, String accessToken) async {
    final res = await _client.put(
      Uri.parse(UserApiConstants.fcmToken),
      headers: UserApiConstants.headers(accessToken: accessToken),
      body: jsonEncode({'fcmToken': fcmToken}),
    ).timeout(_timeout);

    if (res.statusCode != 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(json['message'] ?? 'Error al registrar FCM token');
    }
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:vivia_mobile/core/utils/jwt_utils.dart';
import 'package:vivia_mobile/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:vivia_mobile/features/auth/data/datasources/remote/constants/auth_api_constants.dart';

class AuthHttpClient extends http.BaseClient {
  final http.Client _inner;
  final AuthLocalDatasource _local;
  final VoidCallback _onSessionExpired;

  // Mutex: evita múltiples refresh concurrentes ante varios 401 simultáneos
  Completer<void>? _refreshCompleter;

  AuthHttpClient(this._inner, this._local, this._onSessionExpired);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Pre-check: refrescar proactivamente si el token está a punto de expirar
    var didRefresh = false;
    final currentToken = _local.getAccessToken();
    if (currentToken != null &&
        JwtUtils.isExpiredOrExpiringSoon(currentToken)) {
      await _refreshToken();
      didRefresh = true;
    }

    _injectToken(request);

    final response = await _inner.send(request);

    if (response.statusCode != 401 && response.statusCode != 403) return response;

    // Si ya refrescamos proactivamente, el 401/403 no es por token expirado
    if (didRefresh) return response;

    // Fallback reactivo: 401/403 por clock skew o token expirado en tránsito
    final newToken = await _refreshToken();
    if (newToken == null) return response;

    final retryRequest = _copyRequest(request, newToken);
    return _inner.send(retryRequest);
  }

  // Inyecta el Bearer token si existe y no fue seteado ya en el request
  void _injectToken(http.BaseRequest request) {
    final token = _local.getAccessToken();
    if (token != null && !request.headers.containsKey('Authorization')) {
      request.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Refresca el accessToken usando el refreshToken guardado.
  // Si hay otro refresh en curso, espera su resultado (mutex con Completer).
  // Retorna el nuevo accessToken, o null si el refresh falló.
  Future<String?> _refreshToken() async {
    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      return _local.getAccessToken();
    }

    final storedRefreshToken = _local.getRefreshToken();
    if (storedRefreshToken == null) return null;

    _refreshCompleter = Completer<void>();
    try {
      final res = await _inner
          .post(
            Uri.parse(AuthApiConstants.refresh),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': storedRefreshToken}),
          )
          .timeout(const Duration(seconds: 15));

      final json = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200 && json['success'] == true) {
        final data = json['data'] as Map<String, dynamic>;
        await _local.saveSession(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
          role: _local.getRole() ?? '',
          userName: _local.getUserName() ?? '',
          avatarUrl: _local.getAvatarUrl(),
        );
        _refreshCompleter!.complete();
        return data['accessToken'] as String;
      }

      await _local.clearSession();
      _refreshCompleter!.complete();
      _onSessionExpired();
      return null;
    } catch (_) {
      await _local.clearSession();
      _refreshCompleter!.complete();
      _onSessionExpired();
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  // Crea una copia del request original con el nuevo token en el header.
  // Necesario porque un BaseRequest ya enviado no puede reutilizarse.
  http.BaseRequest _copyRequest(http.BaseRequest original, String newToken) {
    final copy = http.Request(original.method, original.url);
    copy.headers.addAll(original.headers);
    copy.headers['Authorization'] = 'Bearer $newToken';
    if (original is http.Request) {
      copy.bodyBytes = original.bodyBytes;
      copy.encoding = original.encoding;
    }
    return copy;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

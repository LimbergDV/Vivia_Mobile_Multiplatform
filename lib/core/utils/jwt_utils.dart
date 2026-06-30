import 'dart:convert';

class JwtUtils {
  JwtUtils._();

  static Map<String, dynamic> decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Retorna true si el token ya expiró o expirará dentro de [bufferSeconds].
  static bool isExpiredOrExpiringSoon(String token,
      {int bufferSeconds = 60}) {
    final payload = decodePayload(token);
    final exp = payload['exp'];
    if (exp == null) return true;
    final expiry = DateTime.fromMillisecondsSinceEpoch(
        (exp as int) * 1000,
        isUtc: true);
    return DateTime.now()
        .toUtc()
        .isAfter(expiry.subtract(Duration(seconds: bufferSeconds)));
  }
}

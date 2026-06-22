import 'package:shared_preferences/shared_preferences.dart';

// ── Contrato ──────────────────────────────────────────────────────────────
abstract class AuthLocalDatasource {
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String role, // "ROLE_LESSEE" o "ROLE_LESSOR"
  });

  String? getAccessToken();
  String? getRefreshToken();
  String? getRole();
  bool get isLoggedIn;
  Future<void> clearSession();
}

// ── Implementación con SharedPreferences ──────────────────────────────────
class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final SharedPreferences _prefs;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _roleKey = 'user_role';

  AuthLocalDatasourceImpl(this._prefs);

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String role,
  }) async {
    await _prefs.setString(_accessKey, accessToken);
    await _prefs.setString(_refreshKey, refreshToken);
    await _prefs.setString(_roleKey, role);
  }

  @override
  String? getAccessToken() => _prefs.getString(_accessKey);

  @override
  String? getRefreshToken() => _prefs.getString(_refreshKey);

  @override
  String? getRole() => _prefs.getString(_roleKey);

  @override
  bool get isLoggedIn => getAccessToken() != null;

  @override
  Future<void> clearSession() async {
    await _prefs.remove(_accessKey);
    await _prefs.remove(_refreshKey);
    await _prefs.remove(_roleKey);
  }
}

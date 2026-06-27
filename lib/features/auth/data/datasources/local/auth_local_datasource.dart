import 'package:shared_preferences/shared_preferences.dart';

// ── Contrato ──────────────────────────────────────────────────────────────
abstract class AuthLocalDatasource {
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String role,
    required String userName,
    String? avatarUrl,
  });

  String? getAccessToken();
  String? getRefreshToken();
  String? getRole();
  String? getUserName();
  String? getAvatarUrl();
  bool get isLoggedIn;
  Future<void> clearSession();

  bool getLocationPermissionShown();
  Future<void> setLocationPermissionShown();
}

// ── Implementación con SharedPreferences ──────────────────────────────────
class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final SharedPreferences _prefs;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _roleKey = 'user_role';
  static const _userNameKey = 'user_name';
  static const _avatarKey = 'user_avatar_url';
  static const _locationPermissionShownKey = 'has_seen_location_permission';

  AuthLocalDatasourceImpl(this._prefs);

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String role,
    required String userName,
    String? avatarUrl,
  }) async {
    await _prefs.setString(_accessKey, accessToken);
    await _prefs.setString(_refreshKey, refreshToken);
    await _prefs.setString(_roleKey, role);
    await _prefs.setString(_userNameKey, userName);
    if (avatarUrl != null) {
      await _prefs.setString(_avatarKey, avatarUrl);
    } else {
      await _prefs.remove(_avatarKey);
    }
  }

  @override
  String? getAccessToken() => _prefs.getString(_accessKey);

  @override
  String? getRefreshToken() => _prefs.getString(_refreshKey);

  @override
  String? getRole() => _prefs.getString(_roleKey);

  @override
  String? getUserName() => _prefs.getString(_userNameKey);

  @override
  String? getAvatarUrl() => _prefs.getString(_avatarKey);

  @override
  bool get isLoggedIn => getAccessToken() != null;

  @override
  Future<void> clearSession() async {
    await _prefs.remove(_accessKey);
    await _prefs.remove(_refreshKey);
    await _prefs.remove(_roleKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_avatarKey);
  }

  @override
  bool getLocationPermissionShown() =>
      _prefs.getBool(_locationPermissionShownKey) ?? false;

  @override
  Future<void> setLocationPermissionShown() =>
      _prefs.setBool(_locationPermissionShownKey, true);
}

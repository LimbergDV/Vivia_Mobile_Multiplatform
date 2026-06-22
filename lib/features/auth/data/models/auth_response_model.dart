class AuthResponseModel {
  final String accessToken;
  final String refreshToken;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  /// Parsea la respuesta exitosa del backend:
  /// ```json
  /// { "success": true, "data": { "accessToken": "...", "refreshToken": "..." } }
  /// ```
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthResponseModel(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }
}

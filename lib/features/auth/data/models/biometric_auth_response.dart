class BiometricAuthResponse {
  final bool success;
  final BiometricAuthData data;
  final String message;
  final String status;

  BiometricAuthResponse({
    required this.success,
    required this.data,
    required this.message,
    required this.status,
  });

  factory BiometricAuthResponse.fromJson(Map<String, dynamic> json) {
    return BiometricAuthResponse(
      success: json['success'] ?? false,
      data: BiometricAuthData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'message': message,
      'status': status,
    };
  }
}

class BiometricAuthData {
  final String accessToken;
  final String refreshToken;

  BiometricAuthData({
    required this.accessToken,
    required this.refreshToken,
  });

  factory BiometricAuthData.fromJson(Map<String, dynamic> json) {
    return BiometricAuthData(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

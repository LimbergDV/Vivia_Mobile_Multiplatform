import 'dart:convert';

class BiometricChallengeResponse {
  final bool success;
  final Map<String, dynamic> data;
  final String message;
  final String status;

  BiometricChallengeResponse({
    required this.success,
    required this.data,
    required this.message,
    required this.status,
  });

  factory BiometricChallengeResponse.fromJson(Map<String, dynamic> json) {
    print('>>> BiometricChallengeResponse.fromJson - json recibido: $json');
    print('>>> json.keys: ${json.keys}');
    print('>>> json["data"] type: ${json['data'].runtimeType}');
    print('>>> json["data"] value: ${json['data']}');
    print('>>> json["data"] is Map: ${json['data'] is Map}');
    print('>>> json["data"] is Map<String, dynamic>: ${json['data'] is Map<String, dynamic>}');

    final dataValue = json['data'];
    Map<String, dynamic> parsedData = {};

    if (dataValue is Map) {
      print('>>> Convirtiendo Map a Map<String, dynamic>');
      parsedData = Map<String, dynamic>.from(dataValue);
      print('>>> parsedData después de conversión: $parsedData');
    } else if (dataValue is String) {
      print('>>> data es String, intentando parsear JSON');
      try {
        parsedData = jsonDecode(dataValue) as Map<String, dynamic>;
      } catch (e) {
        print('>>> Error parseando JSON string: $e');
      }
    }

    return BiometricChallengeResponse(
      success: json['success'] ?? false,
      data: parsedData,
      message: json['message'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'status': status,
    };
  }

  /// Obtiene el publicKey como JSON string para PasskeyAuthenticator
  String getPublicKeyAsJsonString() {
    if (data.containsKey('publicKey')) {
      return jsonEncode(data['publicKey']);
    }
    // Si no tiene publicKey, intentar usar data directamente
    return jsonEncode(data);
  }
}

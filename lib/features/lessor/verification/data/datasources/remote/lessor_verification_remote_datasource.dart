import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:vivia_mobile/features/lessor/data/datasources/remote/constants/lessor_api_constants.dart';
import 'package:vivia_mobile/features/lessor/verification/data/models/verification_status_model.dart';
import 'package:vivia_mobile/features/lessor/verification/data/models/verification_upload_model.dart';

// ── Contrato ──────────────────────────────────────────────────────────────────
abstract class LessorVerificationRemoteDatasource {
  Future<VerificationStatusModel> getVerificationStatus();
  Future<VerificationUploadModel> requestUploadUrls(
    List<({String documentType, String contentType})> documents,
  );
  Future<void> resetVerification();
  Future<void> uploadDocumentBytes({
    required String presignedUrl,
    required Uint8List bytes,
    required String contentType,
  });
}

// ── Implementación ────────────────────────────────────────────────────────────
class LessorVerificationRemoteDatasourceImpl
    implements LessorVerificationRemoteDatasource {
  final http.Client _client;

  /// Cliente sin interceptor JWT — la presigned URL de S3 rechaza el header
  /// Authorization.
  final http.Client _plainClient;
  static const _timeout = Duration(seconds: 15);

  LessorVerificationRemoteDatasourceImpl(this._client, this._plainClient);

  @override
  Future<VerificationStatusModel> getVerificationStatus() async {
    final res = await _client
        .get(
          Uri.parse(LessorApiConstants.verifications),
          headers: LessorApiConstants.headers(),
        )
        .timeout(_timeout);

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && json['success'] == true) {
      return VerificationStatusModel.fromJson(json);
    }
    throw Exception(
      json['message'] ?? 'Error al obtener el estado de verificación',
    );
  }

  @override
  Future<VerificationUploadModel> requestUploadUrls(
    List<({String documentType, String contentType})> documents,
  ) async {
    final res = await _client
        .post(
          Uri.parse(LessorApiConstants.verificationUploadUrls),
          headers: LessorApiConstants.headers(),
          body: jsonEncode({
            'documents': documents
                .map(
                  (d) => {
                    'documentType': d.documentType,
                    'contentType': d.contentType,
                  },
                )
                .toList(),
          }),
        )
        .timeout(_timeout);

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && json['success'] == true) {
      return VerificationUploadModel.fromJson(json);
    }
    throw Exception(json['message'] ?? 'Error al generar URLs de carga');
  }

  @override
  Future<void> resetVerification() async {
    final res = await _client
        .patch(
          Uri.parse(LessorApiConstants.verifications),
          headers: LessorApiConstants.headers(),
        )
        .timeout(_timeout);

    if (res.statusCode == 200 || res.statusCode == 204) return;

    String message = 'Error al reiniciar la verificación';
    if (res.body.isNotEmpty) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      message = json['message'] as String? ?? message;
    }
    throw Exception(message);
  }

  @override
  Future<void> uploadDocumentBytes({
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
      throw Exception('Error al subir el documento de identidad');
    }
  }
}

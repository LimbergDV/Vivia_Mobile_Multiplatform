import 'dart:io';

import 'package:flutter/material.dart';

import 'package:vivia_mobile/features/lessor/verification/domain/enums/verification_document_type.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/models/lessor_verification.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/usecases/get_verification_status_usecase.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/usecases/request_verification_upload_urls_usecase.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/usecases/reset_verification_usecase.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/usecases/upload_verification_document_usecase.dart';

class VerificationViewModel extends ChangeNotifier {
  final GetVerificationStatusUseCase _getVerificationStatusUseCase;
  final RequestVerificationUploadUrlsUseCase _requestUploadUrlsUseCase;
  final ResetVerificationUseCase _resetVerificationUseCase;
  final UploadVerificationDocumentUseCase _uploadDocumentUseCase;

  VerificationViewModel({
    required GetVerificationStatusUseCase getVerificationStatusUseCase,
    required RequestVerificationUploadUrlsUseCase requestUploadUrlsUseCase,
    required ResetVerificationUseCase resetVerificationUseCase,
    required UploadVerificationDocumentUseCase uploadDocumentUseCase,
  }) : _getVerificationStatusUseCase = getVerificationStatusUseCase,
       _requestUploadUrlsUseCase = requestUploadUrlsUseCase,
       _resetVerificationUseCase = resetVerificationUseCase,
       _uploadDocumentUseCase = uploadDocumentUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  LessorVerification? _verification;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LessorVerification? get verification => _verification;

  List<String> get rejectionReasons =>
      _verification?.rejection?.reasons ?? const [];
  String get rejectionComment => _verification?.rejection?.comment ?? '';

  // ── Captura y staging de documentos ──────────────────────────────────

  final Map<VerificationDocumentType, String> _stagedPaths = {};

  /// Se genera al menos un juego de presigned URLs en este intento; el
  /// backend ya quedó en PENDING_REVIEW y hay que resetear si se abandona.
  bool _uploadUrlsGenerated = false;

  bool _isSubmitting = false;
  String? _submitError;

  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;

  String? stagedPath(VerificationDocumentType type) => _stagedPaths[type];

  bool get hasAllDocuments =>
      VerificationDocumentType.values.every(_stagedPaths.containsKey);

  void stageDocument(VerificationDocumentType type, String path) {
    final previous = _stagedPaths[type];
    if (previous != null && previous != path) {
      _deleteFileSilently(previous);
    }
    _stagedPaths[type] = path;
    notifyListeners();
  }

  /// Limpia el staging y borra los archivos temporales del dispositivo.
  /// Llamar al iniciar el flujo y al abandonarlo.
  void clearStagedDocuments() {
    for (final path in _stagedPaths.values) {
      _deleteFileSilently(path);
    }
    _stagedPaths.clear();
    _uploadUrlsGenerated = false;
    _submitError = null;
    notifyListeners();
  }

  // ── API ───────────────────────────────────────────────────────────────

  /// Consulta GET /lessors/verifications y guarda el resultado.
  Future<void> fetchStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _verification = await _getVerificationStatusUseCase.execute();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reinicia la verificación (PATCH). Retorna true si el reinicio fue
  /// exitoso; la vista decide la navegación.
  Future<bool> retryVerification() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _resetVerificationUseCase.execute();
      _verification = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Envía los tres documentos staged: pide presigned URLs y sube cada
  /// imagen a S3. Retorna true si todo se subió; en fallo se puede volver a
  /// llamar (se generan URLs frescas).
  Future<bool> submitDocuments() async {
    if (!hasAllDocuments) {
      _submitError = 'Faltan documentos por capturar';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _submitError = null;
    notifyListeners();
    try {
      final documents = VerificationDocumentType.values
          .map(
            (type) => (
              documentType: type.apiValue,
              contentType: _contentTypeFor(_stagedPaths[type]!),
            ),
          )
          .toList();

      final plan = await _requestUploadUrlsUseCase.execute(documents);
      _uploadUrlsGenerated = true;

      await Future.wait(
        plan.uploads.map((slot) async {
          final type = VerificationDocumentType.values.firstWhere(
            (t) => t.apiValue == slot.documentType,
          );
          final path = _stagedPaths[type]!;
          final bytes = await File(path).readAsBytes();
          await _uploadDocumentUseCase.execute(
            slot: slot,
            bytes: bytes,
            contentType: _contentTypeFor(path),
          );
        }),
      );

      clearStagedDocuments();
      return true;
    } catch (e) {
      _submitError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Abandono del flujo de captura: si ya se generaron URLs (el backend
  /// quedó en PENDING_REVIEW sin documentos completos), resetea con PATCH en
  /// segundo plano y limpia el staging.
  void abandonCapture() {
    if (_uploadUrlsGenerated) {
      _resetVerificationUseCase.execute().catchError((_) {});
    }
    clearStagedDocuments();
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  String _contentTypeFor(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      _ => 'image/jpeg',
    };
  }

  void _deleteFileSilently(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } catch (_) {
      // Los temporales viven en el caché de la app; si no se puede borrar,
      // el SO lo hará eventualmente.
    }
  }
}

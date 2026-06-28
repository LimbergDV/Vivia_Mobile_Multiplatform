import 'dart:io';
import 'package:vivia_mobile/features/lessor/domain/models/media_manifest_item.dart';
import 'package:vivia_mobile/features/lessor/domain/repositories/lessor_repository.dart';

class PublishPropertyDraftUseCase {
  final LessorRepository _repository;

  PublishPropertyDraftUseCase(this._repository);

  /// Fase A: POST /properties/draft con el cuerpo del formulario + manifiesto.
  /// Fase B: PUT por cada uploadUrl devuelta, en paralelo, con binario puro
  ///         usando http.Client() plano (sin JWT — va directo a S3).
  Future<String> execute({
    required Map<String, dynamic> formBody,
    required List<MediaManifestItem> manifest,
    required Map<String, String> fileKeyToPath,
  }) async {
    final body = {
      ...formBody,
      'mediaManifest': manifest.map((m) => m.toJson()).toList(),
    };

    final draftUpload = await _repository.createDraft(body);

    await Future.wait(
      draftUpload.uploads.map((upload) async {
        final path = fileKeyToPath[upload.fileKey];
        if (path == null) return;
        final bytes = await File(path).readAsBytes();
        final contentType = _contentTypeFromFileKey(upload.fileKey, path);
        await _repository.uploadFile(upload.uploadUrl, contentType, bytes);
      }),
    );

    return draftUpload.draftId;
  }

  String _contentTypeFromFileKey(String fileKey, String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'mp4' => 'video/mp4',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}

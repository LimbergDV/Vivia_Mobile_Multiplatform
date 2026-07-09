import 'dart:io';
import 'package:vivia_mobile/features/lessor/publishing/data/models/draft_upload_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/media_manifest_item.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/repositories/lessor_repository.dart';

class PublishPropertyDraftUseCase {
  final LessorRepository _repository;

  PublishPropertyDraftUseCase(this._repository);

  /// Fase A: POST /properties/draft → devuelve draftId + URLs de S3.
  Future<DraftUploadModel> createDraft({
    required Map<String, dynamic> formBody,
    required List<MediaManifestItem> manifest,
  }) async {
    final body = {
      ...formBody,
      'mediaManifest': manifest.map((m) => m.toJson()).toList(),
    };
    return _repository.createDraft(body);
  }

  /// Fase B: sube cada archivo a su URL de S3 en paralelo.
  Future<void> uploadMedia({
    required List<DraftUploadItem> uploads,
    required Map<String, String> fileKeyToPath,
  }) async {
    await Future.wait(
      uploads.map((upload) async {
        final path = fileKeyToPath[upload.fileKey];
        if (path == null) return;
        final bytes = await File(path).readAsBytes();
        final contentType = _contentTypeFromKey(upload.fileKey, path);
        await _repository.uploadFile(upload.uploadUrl, contentType, bytes);
      }),
    );
  }

  String _contentTypeFromKey(String fileKey, String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'mp4' => 'video/mp4',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}

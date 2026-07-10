import 'dart:io';

import 'package:vivia_mobile/core/utils/media_file_utils.dart';
import 'package:vivia_mobile/shared/property/domain/models/media_manifest_item.dart';
import 'package:vivia_mobile/shared/property/domain/repositories/property_repository.dart';

/// Agrega medios nuevos a una propiedad publicada: crea la sesión de subida
/// (POST /properties/media) y sube cada binario a su URL prefirmada de S3.
/// La publicación es eventual: el backend modera el contenido y confirma
/// por notificación push.
class AddPropertyMediaUseCase {
  final PropertyRepository _repository;

  AddPropertyMediaUseCase(this._repository);

  Future<void> execute({
    required String propertyId,
    required List<MediaManifestItem> manifest,
    required Map<String, String> fileKeyToPath,
  }) async {
    final session = await _repository.createMediaUploadSession({
      'propertyId': propertyId,
      'mediaManifest': manifest.map((m) => m.toJson()).toList(),
    });

    await Future.wait(
      session.uploads.map((upload) async {
        final path = fileKeyToPath[upload.fileKey];
        if (path == null) return;
        final bytes = await File(path).readAsBytes();
        await _repository.uploadFile(
          upload.uploadUrl,
          MediaFileUtils.contentType(path),
          bytes,
        );
      }),
    );
  }
}

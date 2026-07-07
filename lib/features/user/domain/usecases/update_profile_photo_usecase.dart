import 'dart:typed_data';

import 'package:vivia_mobile/features/user/domain/repositories/user_repository.dart';

class UpdateProfilePhotoUseCase {
  final UserRepository _repository;
  UpdateProfilePhotoUseCase(this._repository);

  /// Retorna la URL pública de la foto subida.
  Future<String> execute({
    required Uint8List bytes,
    required String contentType,
  }) =>
      _repository.updateProfilePhoto(bytes: bytes, contentType: contentType);
}

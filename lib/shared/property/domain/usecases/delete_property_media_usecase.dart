import 'package:vivia_mobile/shared/property/domain/repositories/property_repository.dart';

/// Elimina un medio de una propiedad (DELETE /properties/media/{id}).
/// Lanza [MainImageDeletionException] si el medio es la imagen MAIN.
class DeletePropertyMediaUseCase {
  final PropertyRepository _repository;

  DeletePropertyMediaUseCase(this._repository);

  Future<void> execute(String mediaId) => _repository.deleteMedia(mediaId);
}

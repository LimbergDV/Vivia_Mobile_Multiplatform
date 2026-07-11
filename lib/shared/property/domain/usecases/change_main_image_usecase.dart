import 'package:vivia_mobile/shared/property/domain/repositories/property_repository.dart';

/// Cambia la imagen principal de una propiedad (PATCH /properties/media):
/// la MAIN actual pasa a OTHER y la indicada pasa a MAIN, en una operación
/// atómica del backend.
class ChangeMainImageUseCase {
  final PropertyRepository _repository;

  ChangeMainImageUseCase(this._repository);

  Future<void> execute({
    required String mainImageId,
    required String newMainImageId,
  }) =>
      _repository.changeMainImage(mainImageId, newMainImageId);
}

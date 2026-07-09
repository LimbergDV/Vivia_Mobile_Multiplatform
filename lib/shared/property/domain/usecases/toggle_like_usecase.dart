import 'package:vivia_mobile/shared/property/domain/repositories/property_repository.dart';

class ToggleLikeUseCase {
  final PropertyRepository _repository;
  ToggleLikeUseCase(this._repository);

  Future<bool> execute(String propertyId) => _repository.toggleLike(propertyId);
}

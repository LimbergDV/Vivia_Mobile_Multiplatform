import 'package:vivia_mobile/features/home/domain/models/property_model.dart';
import 'package:vivia_mobile/features/home/domain/repositories/property_repository.dart';

class GetPropertiesMeLikesUseCase {
  final PropertyRepository _repository;
  GetPropertiesMeLikesUseCase(this._repository);

  Future<List<PropertyModel>> execute() => _repository.getPropertiesMeLikes();
}

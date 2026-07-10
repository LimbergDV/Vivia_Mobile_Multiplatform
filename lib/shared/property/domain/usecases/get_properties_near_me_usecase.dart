import 'package:vivia_mobile/shared/property/domain/models/property_model.dart';
import 'package:vivia_mobile/shared/property/domain/repositories/property_repository.dart';

class GetPropertiesNearMeUseCase {
  final PropertyRepository _repository;
  GetPropertiesNearMeUseCase(this._repository);

  Future<List<PropertyModel>> execute() => _repository.getPropertiesNearMe();
}

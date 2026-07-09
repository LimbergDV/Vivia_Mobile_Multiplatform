import 'package:vivia_mobile/shared/property/domain/models/property_model.dart';
import 'package:vivia_mobile/shared/property/domain/repositories/property_repository.dart';

class GetPropertiesMeUseCase {
  final PropertyRepository _repository;
  GetPropertiesMeUseCase(this._repository);

  Future<List<PropertyModel>> execute() => _repository.getPropertiesMe();
}

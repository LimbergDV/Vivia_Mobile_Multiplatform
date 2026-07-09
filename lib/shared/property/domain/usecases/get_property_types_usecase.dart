import 'package:vivia_mobile/shared/property/domain/models/property_type_model.dart';
import 'package:vivia_mobile/shared/property/domain/repositories/property_repository.dart';

class GetPropertyTypesUseCase {
  final PropertyRepository _repository;
  GetPropertyTypesUseCase(this._repository);

  Future<List<PropertyTypeModel>> execute() => _repository.getPropertyTypes();
}

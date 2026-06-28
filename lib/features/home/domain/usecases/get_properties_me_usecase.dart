import 'package:vivia_mobile/features/home/domain/models/property_model.dart';
import 'package:vivia_mobile/features/home/domain/repositories/property_repository.dart';

class GetPropertiesMeUseCase {
  final PropertyRepository _repository;
  GetPropertiesMeUseCase(this._repository);

  Future<List<PropertyModel>> execute() => _repository.getPropertiesMe();
}

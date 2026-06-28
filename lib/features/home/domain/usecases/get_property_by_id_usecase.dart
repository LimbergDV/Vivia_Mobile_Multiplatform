import 'package:vivia_mobile/features/home/domain/models/property_detail.dart';
import 'package:vivia_mobile/features/home/domain/repositories/property_repository.dart';

class GetPropertyByIdUseCase {
  final PropertyRepository _repository;
  GetPropertyByIdUseCase(this._repository);

  Future<PropertyDetail> execute(String id) => _repository.getPropertyById(id);
}

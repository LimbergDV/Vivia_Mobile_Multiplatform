import 'package:vivia_mobile/features/lessor/data/models/amenity_model.dart';
import 'package:vivia_mobile/features/lessor/domain/repositories/lessor_repository.dart';

class GetAmenitiesUseCase {
  final LessorRepository _repository;

  GetAmenitiesUseCase(this._repository);

  Future<List<AmenityModel>> execute() => _repository.getAmenities();
}

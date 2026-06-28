import 'package:vivia_mobile/features/lessor/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/domain/repositories/lessor_repository.dart';

class GetNeighborhoodsUseCase {
  final LessorRepository _repository;

  GetNeighborhoodsUseCase(this._repository);

  Future<List<NeighborhoodModel>> execute(String cp) =>
      _repository.getNeighborhoods(cp);
}

import 'package:vivia_mobile/features/home/domain/models/property_media.dart';
import 'package:vivia_mobile/features/home/domain/repositories/property_repository.dart';

class GetPropertyMediaUseCase {
  final PropertyRepository _repository;
  GetPropertyMediaUseCase(this._repository);

  Future<List<PropertyMedia>> execute(String id) =>
      _repository.getPropertyMedia(id);
}

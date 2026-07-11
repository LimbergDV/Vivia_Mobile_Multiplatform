import 'package:vivia_mobile/shared/property/domain/repositories/property_repository.dart';

class UpdatePropertyUseCase {
  final PropertyRepository _repository;
  UpdatePropertyUseCase(this._repository);

  Future<void> execute(String id, Map<String, dynamic> body) =>
      _repository.updateProperty(id, body);
}

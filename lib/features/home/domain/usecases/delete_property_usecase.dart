import 'package:vivia_mobile/features/home/domain/repositories/property_repository.dart';

class DeletePropertyUseCase {
  final PropertyRepository _repository;
  DeletePropertyUseCase(this._repository);

  Future<void> execute(String id) => _repository.deleteProperty(id);
}

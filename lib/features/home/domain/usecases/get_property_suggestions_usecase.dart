import 'package:vivia_mobile/features/home/domain/models/property_model.dart';
import 'package:vivia_mobile/features/home/domain/repositories/property_repository.dart';

class GetPropertySuggestionsUseCase {
  final PropertyRepository _repository;
  GetPropertySuggestionsUseCase(this._repository);

  Future<List<PropertyModel>> execute() => _repository.getPropertySuggestions();
}
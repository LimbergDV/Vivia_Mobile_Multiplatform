import 'package:vivia_mobile/shared/property/domain/models/property_model.dart';
import 'package:vivia_mobile/shared/property/domain/repositories/property_repository.dart';

class GetPropertySuggestionsUseCase {
  final PropertyRepository _repository;
  GetPropertySuggestionsUseCase(this._repository);

  Future<List<PropertyModel>> execute() => _repository.getPropertySuggestions();
}
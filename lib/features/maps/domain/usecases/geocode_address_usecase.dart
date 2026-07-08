import 'package:vivia_mobile/features/maps/domain/models/geocode_result.dart';
import 'package:vivia_mobile/features/maps/domain/repositories/maps_repository.dart';

class GeocodeAddressUseCase {
  final MapsRepository _repository;

  GeocodeAddressUseCase(this._repository);

  Future<GeocodeResult?> execute(String query) =>
      _repository.geocodeAddress(query);
}

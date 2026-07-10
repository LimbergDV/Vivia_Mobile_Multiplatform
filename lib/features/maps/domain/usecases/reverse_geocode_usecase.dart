import 'package:vivia_mobile/features/maps/domain/repositories/maps_repository.dart';

class ReverseGeocodeUseCase {
  final MapsRepository _repository;

  ReverseGeocodeUseCase(this._repository);

  /// Dirección legible del punto, o null si no hay nada cerca (404).
  Future<String?> execute(double lat, double lon) =>
      _repository.reverseGeocode(lat, lon);
}

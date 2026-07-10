import 'package:vivia_mobile/features/maps/domain/models/geocode_result.dart';
import 'package:vivia_mobile/features/maps/domain/repositories/maps_repository.dart';

class GeocodeAddressUseCase {
  final MapsRepository _repository;

  GeocodeAddressUseCase(this._repository);

  /// Mandar todos los campos disponibles: cada uno sube la precisión.
  Future<GeocodeResult?> execute({
    required String cp,
    String? street,
    String? exteriorNumber,
    String? neighborhood,
  }) =>
      _repository.geocodeAddress(
        cp: cp,
        street: street,
        exteriorNumber: exteriorNumber,
        neighborhood: neighborhood,
      );
}

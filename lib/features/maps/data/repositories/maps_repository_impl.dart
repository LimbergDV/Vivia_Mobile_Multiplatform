import 'package:vivia_mobile/features/maps/data/datasources/remote/maps_remote_datasource.dart';
import 'package:vivia_mobile/features/maps/data/models/geocode_address_data_model.dart';
import 'package:vivia_mobile/features/maps/domain/models/geocode_result.dart';
import 'package:vivia_mobile/features/maps/domain/repositories/maps_repository.dart';

class MapsRepositoryImpl implements MapsRepository {
  final MapsRemoteDatasource _remote;

  MapsRepositoryImpl({required MapsRemoteDatasource remote})
      : _remote = remote;

  @override
  Future<GeocodeResult?> geocodeAddress({
    required String cp,
    String? street,
    String? exteriorNumber,
    String? neighborhood,
  }) async {
    final hit = await _remote.geocodeAddress(
      cp: cp,
      calle: street,
      numero: exteriorNumber,
      colonia: neighborhood,
    );
    if (hit == null) return null;
    return _toModel(hit);
  }

  @override
  Future<String?> reverseGeocode(double lat, double lon) =>
      _remote.reverse(lat, lon);

  GeocodeResult _toModel(GeocodeAddressDataModel d) => GeocodeResult(
        lat: d.lat,
        lon: d.lon,
        displayName: d.displayName,
        precision: _parsePrecision(d.precision),
      );

  // Valor desconocido → neighbourhood: se trata como aproximado y la UI
  // pide pin manual, el comportamiento más seguro.
  GeocodePrecision _parsePrecision(String raw) => switch (raw) {
        'exact' => GeocodePrecision.exact,
        'street' => GeocodePrecision.street,
        'postcode' => GeocodePrecision.postcode,
        _ => GeocodePrecision.neighbourhood,
      };
}

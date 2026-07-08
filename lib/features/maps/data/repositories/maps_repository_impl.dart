import 'package:vivia_mobile/features/maps/data/datasources/remote/maps_remote_datasource.dart';
import 'package:vivia_mobile/features/maps/data/models/geocode_result_data_model.dart';
import 'package:vivia_mobile/features/maps/domain/models/geocode_result.dart';
import 'package:vivia_mobile/features/maps/domain/repositories/maps_repository.dart';

class MapsRepositoryImpl implements MapsRepository {
  final MapsRemoteDatasource _remote;

  // Tipos que resuelven al eje de la calle o al centroide de una zona,
  // no al predio exacto (ver integration.md §4).
  static const _approximateTypes = {
    'primary',
    'secondary',
    'tertiary',
    'residential',
    'postcode',
    'administrative',
  };

  MapsRepositoryImpl({required MapsRemoteDatasource remote})
      : _remote = remote;

  @override
  Future<GeocodeResult?> geocodeAddress(String query) async {
    final hits = await _remote.geocode(query, limit: 1);
    if (hits.isEmpty) return null;
    return _toModel(hits.first);
  }

  GeocodeResult _toModel(GeocodeResultDataModel d) => GeocodeResult(
        lat: d.lat,
        lon: d.lon,
        displayName: d.displayName,
        isApproximate: _approximateTypes.contains(d.type),
      );
}

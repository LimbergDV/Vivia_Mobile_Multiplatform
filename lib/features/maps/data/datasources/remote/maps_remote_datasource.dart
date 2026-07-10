import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vivia_mobile/features/maps/data/datasources/remote/constants/maps_api_constants.dart';
import 'package:vivia_mobile/features/maps/data/models/geocode_address_data_model.dart';

abstract class MapsRemoteDatasource {
  /// Geocoding estructurado. Regla de oro del servicio: mandar todos los
  /// campos disponibles — cada uno sube la precisión posible.
  /// null = 404: la dirección no resuelve dentro de la zona de servicio.
  Future<GeocodeAddressDataModel?> geocodeAddress({
    required String cp,
    String? calle,
    String? numero,
    String? colonia,
  });

  /// display_name de la coordenada, o null (404) si no hay dirección
  /// cercana — "ubicación sin dirección", no una falla del servicio.
  Future<String?> reverse(double lat, double lon);
}

class MapsRemoteDatasourceImpl implements MapsRemoteDatasource {
  final http.Client _client;
  static const _timeout = Duration(seconds: 10);

  MapsRemoteDatasourceImpl(this._client);

  @override
  Future<GeocodeAddressDataModel?> geocodeAddress({
    required String cp,
    String? calle,
    String? numero,
    String? colonia,
  }) async {
    final uri = Uri.parse(MapsApiConstants.geocodeAddress).replace(
      queryParameters: {
        'cp': cp,
        if (calle != null && calle.trim().isNotEmpty) 'calle': calle.trim(),
        if (numero != null && numero.trim().isNotEmpty) 'numero': numero.trim(),
        if (colonia != null && colonia.trim().isNotEmpty)
          'colonia': colonia.trim(),
      },
    );
    final res = await _client.get(uri).timeout(_timeout);
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al geocodificar');
    }
    return GeocodeAddressDataModel.fromJson(
      jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
    );
  }

  @override
  Future<String?> reverse(double lat, double lon) async {
    final uri = Uri.parse(MapsApiConstants.reverse).replace(
      queryParameters: {'lat': '$lat', 'lon': '$lon'},
    );
    final res = await _client.get(uri).timeout(_timeout);
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} en reverse geocoding');
    }
    final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return json['display_name'] as String?;
  }
}

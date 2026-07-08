import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vivia_mobile/features/maps/data/datasources/remote/constants/maps_api_constants.dart';
import 'package:vivia_mobile/features/maps/data/models/geocode_result_data_model.dart';

abstract class MapsRemoteDatasource {
  /// Candidatos ordenados por relevancia. Lista vacía = sin resultados
  /// (no es un error según el contrato del servicio).
  Future<List<GeocodeResultDataModel>> geocode(String query, {int limit});
}

class MapsRemoteDatasourceImpl implements MapsRemoteDatasource {
  final http.Client _client;
  static const _timeout = Duration(seconds: 10);

  MapsRemoteDatasourceImpl(this._client);

  @override
  Future<List<GeocodeResultDataModel>> geocode(
    String query, {
    int limit = 1,
  }) async {
    final uri = Uri.parse(MapsApiConstants.geocode).replace(
      queryParameters: {'q': query, 'limit': '$limit'},
    );
    final res = await _client.get(uri).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al geocodificar');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
    return data
        .map((e) => GeocodeResultDataModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

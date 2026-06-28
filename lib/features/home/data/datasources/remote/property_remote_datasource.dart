import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:vivia_mobile/features/home/data/datasources/remote/constants/property_api_constants.dart';
import 'package:vivia_mobile/features/home/data/models/property_summary_model.dart';
import 'package:vivia_mobile/features/home/domain/models/property_type_model.dart';

// ── Contrato ──────────────────────────────────────────────────────────────────
abstract class PropertyRemoteDatasource {
  Future<List<PropertyTypeModel>> getPropertyTypes();
  Future<List<PropertySummaryModel>> getPropertiesMe();
  Future<List<PropertySummaryModel>> getPropertiesMeLikes();
  Future<List<PropertySummaryModel>> getPropertySuggestions();
}

// ── Implementación ────────────────────────────────────────────────────────────
class PropertyRemoteDatasourceImpl implements PropertyRemoteDatasource {
  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  PropertyRemoteDatasourceImpl(this._client);

  List<T> _parseList<T>(
      http.Response res,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && json['success'] == true) {
      final data = json['data'] as List<dynamic>;
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception(json['message'] ?? 'Error ${res.statusCode}');
  }

  @override
  Future<List<PropertyTypeModel>> getPropertyTypes() async {
    final res = await _client.get(
      Uri.parse(PropertyApiConstants.types),
      headers: PropertyApiConstants.headers(),
    ).timeout(_timeout);
    return _parseList(res, PropertyTypeModel.fromJson);
  }

  @override
  Future<List<PropertySummaryModel>> getPropertiesMe() async {
    final res = await _client.get(
      Uri.parse(PropertyApiConstants.propertiesMe),
      headers: PropertyApiConstants.headers(),
    ).timeout(_timeout);
    return _parseList(res, PropertySummaryModel.fromJson);
  }

  @override
  Future<List<PropertySummaryModel>> getPropertiesMeLikes() async {
    final res = await _client.get(
      Uri.parse(PropertyApiConstants.propertiesMeLikes),
      headers: PropertyApiConstants.headers(),
    ).timeout(_timeout);
    return _parseList(res, PropertySummaryModel.fromJson);
  }

  @override
  Future<List<PropertySummaryModel>> getPropertySuggestions() async {
    final res = await _client.get(
      Uri.parse(PropertyApiConstants.propertiesSuggestions),
      headers: PropertyApiConstants.headers(),
    ).timeout(_timeout);
    return _parseList(res, PropertySummaryModel.fromJson);
  }
}
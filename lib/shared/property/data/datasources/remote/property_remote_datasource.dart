import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:vivia_mobile/shared/property/data/datasources/remote/constants/property_api_constants.dart';
import 'package:vivia_mobile/shared/property/data/models/property_summary_model.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_detail.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_media.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_type_model.dart';

// ── Contrato ──────────────────────────────────────────────────────────────────
abstract class PropertyRemoteDatasource {
  Future<List<PropertyTypeModel>> getPropertyTypes();
  Future<List<PropertySummaryModel>> getPropertiesMe();
  Future<List<PropertySummaryModel>> getPropertiesMeLikes();
  Future<PropertyDetail> getPropertyById(String id);
  Future<List<PropertyMedia>> getPropertyMedia(String id);
  Future<List<PropertySummaryModel>> getPropertySuggestions();
  Future<List<PropertySummaryModel>> getPropertiesNearMe();
  Future<bool> toggleLike(String propertyId);
  Future<void> deleteProperty(String id);
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

  T _parseObject<T>(
    http.Response res,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && json['success'] == true) {
      return fromJson(json['data'] as Map<String, dynamic>);
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
  Future<PropertyDetail> getPropertyById(String id) async {
    final res = await _client.get(
      Uri.parse(PropertyApiConstants.propertyDetail(id)),
      headers: PropertyApiConstants.headers(),
    ).timeout(_timeout);
    return _parseObject(res, PropertyDetail.fromResponse);
  }

  @override
  Future<List<PropertyMedia>> getPropertyMedia(String id) async {
    final res = await _client.get(
      Uri.parse(PropertyApiConstants.propertyMedia(id)),
      headers: PropertyApiConstants.headers(),
    ).timeout(_timeout);
    return _parseList(res, PropertyMedia.fromJson);
  }

  @override
  Future<List<PropertySummaryModel>> getPropertySuggestions() async {
    final res = await _client.get(
      Uri.parse(PropertyApiConstants.propertiesSuggestions),
      headers: PropertyApiConstants.headers(),
    ).timeout(_timeout);
    return _parseList(res, PropertySummaryModel.fromJson);
  }

  @override
  Future<List<PropertySummaryModel>> getPropertiesNearMe() async {
    // TODO(debug): logs temporales para diagnosticar /properties/nearme
    debugPrint('[nearme] GET ${PropertyApiConstants.propertiesNearMe}');
    final res = await _client.get(
      Uri.parse(PropertyApiConstants.propertiesNearMe),
      headers: PropertyApiConstants.headers(),
    ).timeout(_timeout);
    debugPrint('[nearme] status=${res.statusCode} body=${res.body}');
    return _parseList(res, PropertySummaryModel.fromJson);
  }

  @override
  Future<bool> toggleLike(String propertyId) async {
    final res = await _client.put(
      Uri.parse(PropertyApiConstants.propertiesMeLikes),
      headers: {
        ...PropertyApiConstants.headers(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'propertyId': propertyId}),
    ).timeout(_timeout);
    return _parseObject(res, (data) => data['liked'] as bool);
  }

  @override
  Future<void> deleteProperty(String id) async {
    final res = await _client.delete(
      Uri.parse(PropertyApiConstants.propertyDelete(id)),
      headers: PropertyApiConstants.headers(),
    ).timeout(_timeout);
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200 || json['success'] != true) {
      throw Exception(json['message'] ?? 'Error ${res.statusCode}');
    }
  }
}

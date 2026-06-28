import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vivia_mobile/core/http/auth_http_client.dart';
import 'package:vivia_mobile/features/lessor/data/datasources/remote/constants/lessor_api_constants.dart';
import 'package:vivia_mobile/features/lessor/data/models/amenity_model.dart';
import 'package:vivia_mobile/features/lessor/data/models/draft_upload_model.dart';
import 'package:vivia_mobile/features/lessor/data/models/neighborhood_model.dart';

abstract class LessorRemoteDatasource {
  Future<List<NeighborhoodModel>> getNeighborhoodsByPostalCode(String cp);
  Future<List<AmenityModel>> getAmenities();
  Future<DraftUploadModel> createDraft(Map<String, dynamic> body);
  Future<void> uploadFile(
      String uploadUrl, String contentType, List<int> bytes);
}

class LessorRemoteDatasourceImpl implements LessorRemoteDatasource {
  final AuthHttpClient _authClient;
  final http.Client _plainClient;

  LessorRemoteDatasourceImpl(this._authClient, this._plainClient);

  @override
  Future<List<NeighborhoodModel>> getNeighborhoodsByPostalCode(
      String cp) async {
    final response = await _authClient.get(
      Uri.parse(LessorApiConstants.neighborhoodsByPostalCode(cp)),
      headers: LessorApiConstants.headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al obtener colonias: ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>;
    return data
        .map((e) => NeighborhoodModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AmenityModel>> getAmenities() async {
    final response = await _authClient.get(
      Uri.parse(LessorApiConstants.amenities),
      headers: LessorApiConstants.headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al obtener amenidades: ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>;
    return data
        .map((e) => AmenityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DraftUploadModel> createDraft(Map<String, dynamic> body) async {
    final response = await _authClient.post(
      Uri.parse(LessorApiConstants.propertiesDraft),
      headers: LessorApiConstants.headers(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear draft: ${response.statusCode}');
    }
    return DraftUploadModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<void> uploadFile(
      String uploadUrl, String contentType, List<int> bytes) async {
    final response = await _plainClient.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al subir archivo: ${response.statusCode}');
    }
  }
}

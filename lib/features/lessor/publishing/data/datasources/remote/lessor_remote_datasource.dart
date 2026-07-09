import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vivia_mobile/core/http/auth_http_client.dart';
import 'package:vivia_mobile/features/lessor/data/datasources/remote/constants/lessor_api_constants.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/amenity_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/draft_upload_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/draft_status_event.dart';

abstract class LessorRemoteDatasource {
  Future<List<NeighborhoodModel>> getNeighborhoodsByPostalCode(String cp);
  Future<List<AmenityModel>> getAmenities();
  Future<DraftUploadModel> createDraft(Map<String, dynamic> body);
  Future<void> uploadFile(
    String uploadUrl,
    String contentType,
    List<int> bytes,
  );
  Stream<DraftStatusEvent> watchDraftStatus(String draftId);
}

class LessorRemoteDatasourceImpl implements LessorRemoteDatasource {
  final AuthHttpClient _authClient;
  final http.Client _plainClient;

  LessorRemoteDatasourceImpl(this._authClient, this._plainClient);

  @override
  Future<List<NeighborhoodModel>> getNeighborhoodsByPostalCode(
    String cp,
  ) async {
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
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> uploadFile(
    String uploadUrl,
    String contentType,
    List<int> bytes,
  ) async {
    final response = await _plainClient.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al subir archivo: ${response.statusCode}');
    }
  }

  @override
  Stream<DraftStatusEvent> watchDraftStatus(String draftId) async* {
    bool done = false;
    while (!done) {
      try {
        await for (final event in _connectOnce(draftId)) {
          yield event;
          if (event is DraftPublicationSuccess ||
              event is DraftPublicationFailed) {
            done = true;
            break;
          }
        }
        if (!done) await Future.delayed(const Duration(seconds: 2));
      } catch (_) {
        if (!done) await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  Stream<DraftStatusEvent> _connectOnce(String draftId) async* {
    final request = http.Request(
      'GET',
      Uri.parse(LessorApiConstants.draftStatusStream(draftId)),
    );
    request.headers['Accept'] = 'text/event-stream';

    final streamed = await _authClient.send(request);

    if (streamed.statusCode != 200) {
      final body = await streamed.stream.transform(const Utf8Decoder()).join();
      throw Exception('SSE error ${streamed.statusCode}: $body');
    }

    String? eventType;
    final buf = StringBuffer();

    await for (final line
        in streamed.stream
            .transform(const Utf8Decoder())
            .transform(const LineSplitter())) {
      if (line.startsWith('event:')) {
        eventType = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        buf.write(line.substring(5).trim());
      } else if (line.isEmpty && eventType != null && buf.isNotEmpty) {
        if (eventType != 'status_update') {
          try {
            final payload = jsonDecode(buf.toString()) as Map<String, dynamic>;
            final ev = switch (eventType) {
              'publication_success' => DraftPublicationSuccess.fromJson(
                payload,
              ),
              'publication_failed' => DraftPublicationFailed.fromJson(payload),
              _ => null,
            };
            if (ev != null) yield ev;
          } catch (_) {}
        }
        eventType = null;
        buf.clear();
      }
    }
  }
}

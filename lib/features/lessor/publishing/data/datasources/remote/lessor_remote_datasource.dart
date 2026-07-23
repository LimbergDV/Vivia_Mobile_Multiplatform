import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vivia_mobile/core/http/auth_http_client.dart';
import 'package:vivia_mobile/features/lessor/data/datasources/remote/constants/lessor_api_constants.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/amenity_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/draft_upload_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/ai_content_event.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/draft_status_event.dart';
import 'package:vivia_mobile/features/premium/domain/exceptions/premium_required_exception.dart';

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
  Stream<AiContentEvent> generateAiContent(Map<String, dynamic> draft);
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
    if (response.statusCode == 403) {
      throw const PremiumRequiredException();
    }
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

  @override
  Stream<AiContentEvent> generateAiContent(Map<String, dynamic> draft) async* {
    final request = http.Request(
      'POST',
      Uri.parse(LessorApiConstants.llmContentGenerations),
    );
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'text/event-stream';
    request.body = jsonEncode({'draft': draft});

    final http.StreamedResponse streamed;
    try {
      streamed = await _authClient.send(request);
    } catch (e) {
      throw Exception('Error de red: $e');
    }

    if (streamed.statusCode == 401) {
      await streamed.stream.drain<void>();
      throw Exception('No autorizado. Vuelve a iniciar sesión.');
    }
    if (streamed.statusCode == 403) {
      final body = await streamed.stream.transform(const Utf8Decoder()).join();
      final parsed = jsonDecode(body) as Map<String, dynamic>?;
      final detail = parsed?['detail'];
      final code = detail is Map ? detail['code'] as String? : null;
      if (code == 'premium_required') {
        yield const AiContentPremiumRequired();
        return;
      }
      throw Exception('Acceso denegado.');
    }
    if (streamed.statusCode == 422) {
      final body = await streamed.stream.transform(const Utf8Decoder()).join();
      throw Exception('Datos insuficientes (422): $body');
    }
    if (streamed.statusCode == 503) {
      final body = await streamed.stream.transform(const Utf8Decoder()).join();
      final parsed = jsonDecode(body) as Map<String, dynamic>?;
      final detail = parsed?['detail'];
      final code = detail is Map ? detail['code'] as String? : null;
      if (code == 'subscription_check_failed') {
        yield const AiContentSubscriptionCheckFailed();
        return;
      }
      throw Exception('Servicio no disponible. Intenta en unos momentos.');
    }
    if (streamed.statusCode != 200) {
      final body = await streamed.stream.transform(const Utf8Decoder()).join();
      throw Exception('Error del servidor (${streamed.statusCode}): $body');
    }

    String? eventType;
    final buf = StringBuffer();

    await for (final line in streamed.stream
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())) {
      if (line.startsWith('event:')) {
        eventType = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        buf.write(line.substring(5).trim());
      } else if (line.isEmpty && eventType != null && buf.isNotEmpty) {
        try {
          final payload = jsonDecode(buf.toString()) as Map<String, dynamic>;
          final ev = switch (eventType) {
            'queued' => AiContentQueued(
                (payload['position'] as num?)?.toInt() ?? 0,
              ),
            'title' => AiContentTitle(payload['text'] as String? ?? ''),
            'delta' => AiContentDelta(payload['text'] as String? ?? ''),
            'done' => AiContentDone(
                generationId: payload['generationId'] as String? ?? '',
                title: payload['title'] as String? ?? '',
                description: payload['description'] as String? ?? '',
              ),
            'error' => AiContentError(
                payload['detail'] as String? ?? 'Error desconocido',
              ),
            _ => null,
          };
          if (ev != null) yield ev;
        } catch (_) {}
        eventType = null;
        buf.clear();
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
        try {
          final payload = jsonDecode(buf.toString()) as Map<String, dynamic>;
          final ev = switch (eventType) {
            'status_update' => DraftStatusUpdate.fromJson(payload),
            'publication_success' => DraftPublicationSuccess.fromJson(payload),
            'publication_failed' => DraftPublicationFailed.fromJson(payload),
            _ => null,
          };
          if (ev != null) yield ev;
        } catch (_) {}
        eventType = null;
        buf.clear();
      }
    }
  }
}

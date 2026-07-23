import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vivia_mobile/shared/chat/data/datasources/remote/constants/chat_api_constants.dart';
import 'package:vivia_mobile/shared/chat/data/models/conversation_model.dart';
import 'package:vivia_mobile/shared/chat/data/models/message_model.dart';

abstract class ChatRemoteDatasource {
  Future<List<ConversationModel>> getConversations();
  Future<List<MessageModel>> getMessages(
    String conversationId, {
    String? before,
    int limit = 50,
  });
  Future<ConversationModel> createConversation({
    required String otherUserId,
    required String otherUserRole,
    String? propertyId,
    String? propertyTitle,
    String? requesterName,
    String? requesterPhotoUrl,
    String? otherUserName,
    String? otherUserPhotoUrl,
  });
  Future<void> deleteConversation(String conversationId);
}

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  ChatRemoteDatasourceImpl(this._client);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  @override
  Future<List<ConversationModel>> getConversations() async {
    final res = await _client
        .get(Uri.parse(ChatApiConstants.conversations), headers: _headers)
        .timeout(_timeout);

    _assertOk(res, 'Error al obtener conversaciones');
    final raw = jsonDecode(res.body);
    final data = raw is List
        ? raw
        : (raw as Map<String, dynamic>)['data'] as List<dynamic>;
    return (data as List<dynamic>)
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MessageModel>> getMessages(
    String conversationId, {
    String? before,
    int limit = 50,
  }) async {
    final url = ChatApiConstants.conversationMessages(
      conversationId,
      before: before,
      limit: limit,
    );
    final res = await _client
        .get(Uri.parse(url), headers: _headers)
        .timeout(_timeout);

    _assertOk(res, 'Error al obtener mensajes');
    final raw = jsonDecode(res.body);
    final data = raw is List
        ? raw
        : (raw as Map<String, dynamic>)['data'] as List<dynamic>;
    return (data as List<dynamic>)
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ConversationModel> createConversation({
    required String otherUserId,
    required String otherUserRole,
    String? propertyId,
    String? propertyTitle,
    String? requesterName,
    String? requesterPhotoUrl,
    String? otherUserName,
    String? otherUserPhotoUrl,
  }) async {
    final payload = <String, dynamic>{
      'otherUserId': otherUserId,
      'otherUserRole': otherUserRole,
      if (propertyId != null) 'propertyId': propertyId,
      if (propertyTitle != null) 'propertyTitle': propertyTitle,
      if (requesterName != null) 'requesterName': requesterName,
      if (requesterPhotoUrl != null) 'requesterPhotoUrl': requesterPhotoUrl,
      if (otherUserName != null) 'otherUserName': otherUserName,
      if (otherUserPhotoUrl != null) 'otherUserPhotoUrl': otherUserPhotoUrl,
    };
    final res = await _client
        .post(
          Uri.parse(ChatApiConstants.conversations),
          headers: _headers,
          body: jsonEncode(payload),
        )
        .timeout(_timeout);

    _assertOk(res, 'Error al crear conversación');
    final raw = jsonDecode(res.body) as Map<String, dynamic>;
    final conversationJson = (raw['data'] is Map<String, dynamic>)
        ? raw['data'] as Map<String, dynamic>
        : raw;
    return ConversationModel.fromJson(conversationJson);
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    final res = await _client
        .delete(
          Uri.parse(ChatApiConstants.conversationById(conversationId)),
          headers: _headers,
        )
        .timeout(_timeout);

    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Error al eliminar conversación');
    }
  }

  void _assertOk(http.Response res, String defaultMsg) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = defaultMsg;
      try {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final rawMsg = json['message'];
        // NestJS devuelve `message` como String o como List<String>
        // (errores de validación). Aceptamos ambos.
        if (rawMsg is String) {
          msg = rawMsg;
        } else if (rawMsg is List && rawMsg.isNotEmpty) {
          msg = rawMsg.join('\n');
        }
      } catch (_) {}
      throw Exception('$msg (${res.statusCode})');
    }
  }
}

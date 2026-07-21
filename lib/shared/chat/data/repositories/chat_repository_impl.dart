import 'package:vivia_mobile/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:vivia_mobile/shared/chat/data/datasources/remote/chat_remote_datasource.dart';
import 'package:vivia_mobile/shared/chat/data/datasources/remote/chat_websocket_datasource.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_message.dart';
import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource _remote;
  final ChatWebSocketDatasource _ws;
  final AuthLocalDatasource _local;

  ChatRepositoryImpl({
    required ChatRemoteDatasource remote,
    required ChatWebSocketDatasource ws,
    required AuthLocalDatasource local,
  })  : _remote = remote,
        _ws = ws,
        _local = local;

  String get _currentUserId => _local.getUserId() ?? '';

  // ── REST ──────────────────────────────────────────────────────────────────
  @override
  Future<List<ChatConversation>> getConversations() async {
    final models = await _remote.getConversations();
    return models.map((m) => m.toDomain(_currentUserId)).toList();
  }

  @override
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    String? before,
    int limit = 50,
  }) async {
    final models = await _remote.getMessages(
      conversationId,
      before: before,
      limit: limit,
    );
    return models.map((m) => m.toDomain(_currentUserId)).toList();
  }

  @override
  Future<ChatConversation> createConversation({
    required String otherUserId,
    required String otherUserRole,
    String? propertyId,
    String? propertyTitle,
    String? requesterName,
    String? requesterPhotoUrl,
    String? otherUserName,
    String? otherUserPhotoUrl,
  }) async {
    final model = await _remote.createConversation(
      otherUserId: otherUserId,
      otherUserRole: otherUserRole,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      requesterName: requesterName,
      requesterPhotoUrl: requesterPhotoUrl,
      otherUserName: otherUserName,
      otherUserPhotoUrl: otherUserPhotoUrl,
    );
    return model.toDomain(_currentUserId);
  }

  @override
  Future<void> deleteConversation(String conversationId) =>
      _remote.deleteConversation(conversationId);

  // ── WebSocket ─────────────────────────────────────────────────────────────
  @override
  Stream<Map<String, dynamic>> get wsEvents => _ws.events;

  @override
  Future<void> connectWebSocket() => _ws.connect();

  @override
  void disconnectWebSocket() => _ws.disconnect();

  @override
  void joinConversation(String conversationId) {
    _ws.registerJoinedConversation(conversationId);
    _ws.send('joinConversation', {'conversationId': conversationId});
  }

  @override
  void markRead(String conversationId) =>
      _ws.send('markRead', {'conversationId': conversationId});

  @override
  void sendMessage(String conversationId, String content) =>
      _ws.send('newMessage', {'conversationId': conversationId, 'content': content});

  @override
  void sendTyping(String conversationId) =>
      _ws.send('typing', {'conversationId': conversationId});

  @override
  void deleteMessage(String messageId) =>
      _ws.send('deleteMessage', {'messageId': messageId});

  @override
  void editMessage(String messageId, String content) =>
      _ws.send('editMessage', {'messageId': messageId, 'content': content});
}

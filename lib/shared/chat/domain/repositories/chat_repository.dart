import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_message.dart';

abstract class ChatRepository {
  // ── REST ─────────────────────────────────────────────────────────────────
  Future<List<ChatConversation>> getConversations();
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    String? before,
    int limit = 50,
  });
  Future<ChatConversation> createConversation({
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

  // ── WebSocket ─────────────────────────────────────────────────────────────
  Stream<Map<String, dynamic>> get wsEvents;
  Future<void> connectWebSocket();
  void disconnectWebSocket();
  void joinConversation(String conversationId);
  void markRead(String conversationId);
  void sendMessage(String conversationId, String content, {required String localId});
  void acknowledgeMessage(String localId);
  void retryMessage(String localId);
  void sendTyping(String conversationId);
  void deleteMessage(String messageId);
  void editMessage(String messageId, String content);
}

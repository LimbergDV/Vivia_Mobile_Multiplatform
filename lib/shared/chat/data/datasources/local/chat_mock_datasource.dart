import 'package:vivia_mobile/shared/chat/domain/enums/message_status.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_message.dart';

abstract class ChatMockDatasource {
  Future<List<ChatConversation>> getConversations();
  Future<List<ChatMessage>> getMessages(String conversationId);
}

class ChatMockDatasourceImpl implements ChatMockDatasource {
  static const _lorem =
      'Lorem Ipsum is simply dummy text of the proprapre and...';
  static const _delay = Duration(milliseconds: 400);

  @override
  Future<List<ChatConversation>> getConversations() async {
    await Future.delayed(_delay);
    return List.generate(12, _buildConversation);
  }

  ChatConversation _buildConversation(int index) {
    final unread = index == 1;
    return ChatConversation(
      id: 'conversation_$index',
      name: 'Arturo Gomez Alcazar',
      avatarUrl: 'https://i.pravatar.cc/150?img=${(index % 70) + 1}',
      lastMessage: _lorem,
      lastMessageAt: DateTime(2026, 6, 9, 11, 52),
      unreadCount: unread ? 1 : 0,
      lastMessageIsMine: !unread,
      lastMessageStatus: MessageStatus.read,
    );
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    await Future.delayed(_delay);
    return [
      ChatMessage(
        id: '${conversationId}_1',
        text: _lorem,
        sentAt: DateTime(2026, 6, 9, 22, 39),
        isMine: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '${conversationId}_2',
        text: _lorem,
        sentAt: DateTime(2026, 6, 9, 22, 58),
        isMine: false,
      ),
      ChatMessage(
        id: '${conversationId}_3',
        text: _lorem,
        sentAt: DateTime(2026, 6, 9, 22, 59),
        isMine: false,
        status: MessageStatus.read,
      ),
    ];
  }
}

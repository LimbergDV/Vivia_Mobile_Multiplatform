import 'package:vivia_mobile/shared/chat/domain/enums/message_status.dart';

class ChatConversation {
  final String id;
  final String name;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool lastMessageIsMine;
  final MessageStatus lastMessageStatus;

  const ChatConversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageAt,
    this.avatarUrl,
    this.unreadCount = 0,
    this.lastMessageIsMine = false,
    this.lastMessageStatus = MessageStatus.read,
  });

  bool get hasUnread => unreadCount > 0;
}

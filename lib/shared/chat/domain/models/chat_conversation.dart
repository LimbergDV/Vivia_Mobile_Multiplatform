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

  // Campos reales del backend
  final String participantOneId;
  final String participantTwoId;
  final String? propertyId;
  final String? propertyTitle;

  const ChatConversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.participantOneId,
    required this.participantTwoId,
    this.avatarUrl,
    this.unreadCount = 0,
    this.lastMessageIsMine = false,
    this.lastMessageStatus = MessageStatus.read,
    this.propertyId,
    this.propertyTitle,
  });

  bool get hasUnread => unreadCount > 0;
}

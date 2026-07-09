import 'package:vivia_mobile/shared/chat/domain/enums/message_status.dart';

class ChatMessage {
  final String id;
  final String text;
  final DateTime sentAt;
  final bool isMine;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sentAt,
    required this.isMine,
    this.status = MessageStatus.sent,
  });
}

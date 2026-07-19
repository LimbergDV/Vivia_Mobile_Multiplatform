import 'package:vivia_mobile/shared/chat/domain/enums/message_status.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool isMine;
  final MessageStatus status;

  // Campos reales del backend
  final String type; // 'text' | 'document'
  final String? documentUrl;
  final String? documentName;
  final String? documentMimeType;
  final DateTime? deletedAt;
  final DateTime? editedAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    required this.isMine,
    this.status = MessageStatus.sent,
    this.type = 'text',
    this.documentUrl,
    this.documentName,
    this.documentMimeType,
    this.deletedAt,
    this.editedAt,
  });

  bool get isDeleted => deletedAt != null;
  bool get isEdited => editedAt != null;

  bool canDelete(DateTime now) =>
      isMine && now.difference(sentAt).inMinutes < 5;

  bool canEdit(DateTime now) =>
      isMine && type == 'text' && !isDeleted && now.difference(sentAt).inMinutes <= 10;

  ChatMessage copyWith({
    String? text,
    MessageStatus? status,
    DateTime? deletedAt,
    DateTime? editedAt,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      text: text ?? this.text,
      sentAt: sentAt,
      isMine: isMine,
      status: status ?? this.status,
      type: type,
      documentUrl: documentUrl,
      documentName: documentName,
      documentMimeType: documentMimeType,
      deletedAt: deletedAt ?? this.deletedAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}

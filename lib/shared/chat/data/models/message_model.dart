import 'package:vivia_mobile/shared/chat/domain/enums/message_status.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_message.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String type;
  final String? content;
  final String? documentUrl;
  final String? documentName;
  final String? documentMimeType;
  final int? documentSizeBytes;
  final DateTime? readAt;
  final DateTime? deletedAt;
  final DateTime? editedAt;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    this.content,
    this.documentUrl,
    this.documentName,
    this.documentMimeType,
    this.documentSizeBytes,
    this.readAt,
    this.deletedAt,
    this.editedAt,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) =>
        v == null ? null : DateTime.parse(v as String).toLocal();

    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      type: json['type'] as String? ?? 'text',
      content: json['content'] as String?,
      documentUrl: json['documentUrl'] as String?,
      documentName: json['documentName'] as String?,
      documentMimeType: json['documentMimeType'] as String?,
      documentSizeBytes: json['documentSizeBytes'] as int?,
      readAt: parseDate(json['readAt']),
      deletedAt: parseDate(json['deletedAt']),
      editedAt: parseDate(json['editedAt']),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  ChatMessage toDomain(String currentUserId) {
    final isMine = senderId == currentUserId;
    final text = deletedAt != null
        ? ''
        : (type == 'document' ? (documentName ?? '[Documento]') : (content ?? ''));

    return ChatMessage(
      id: id,
      senderId: senderId,
      text: text,
      sentAt: createdAt,
      isMine: isMine,
      type: type,
      documentUrl: documentUrl,
      documentName: documentName,
      documentMimeType: documentMimeType,
      deletedAt: deletedAt,
      editedAt: editedAt,
      status: (isMine && readAt != null) ? MessageStatus.read : MessageStatus.sent,
    );
  }
}

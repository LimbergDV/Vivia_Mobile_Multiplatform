import 'package:vivia_mobile/shared/chat/domain/enums/message_status.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';

class ConversationModel {
  final String id;
  final String participantOneId;
  final String participantTwoId;
  final String? propertyId;
  final String? propertyTitle;
  final DateTime lastMessageAt;

  // Calculados por el servidor
  final String? lastMessageContent;
  final String? lastMessageType;
  final int unreadCount;
  final String? participantOneName;
  final String? participantOnePhotoUrl;
  final String? participantTwoName;
  final String? participantTwoPhotoUrl;

  const ConversationModel({
    required this.id,
    required this.participantOneId,
    required this.participantTwoId,
    this.propertyId,
    this.propertyTitle,
    required this.lastMessageAt,
    this.lastMessageContent,
    this.lastMessageType,
    this.unreadCount = 0,
    this.participantOneName,
    this.participantOnePhotoUrl,
    this.participantTwoName,
    this.participantTwoPhotoUrl,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      participantOneId: json['participantOneId'] as String,
      participantTwoId: json['participantTwoId'] as String,
      propertyId: json['propertyId'] as String?,
      propertyTitle: json['propertyTitle'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String).toLocal()
          : DateTime.now(),
      lastMessageContent: json['lastMessageContent'] as String?,
      lastMessageType: json['lastMessageType'] as String?,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      participantOneName: json['participantOneName'] as String?,
      participantOnePhotoUrl: json['participantOnePhotoUrl'] as String?,
      participantTwoName: json['participantTwoName'] as String?,
      participantTwoPhotoUrl: json['participantTwoPhotoUrl'] as String?,
    );
  }

  ChatConversation toDomain(String currentUserId) {
    final isParticipantOne = currentUserId == participantOneId;
    final otherName = isParticipantOne
        ? (participantTwoName ?? 'Usuario')
        : (participantOneName ?? 'Usuario');
    final otherPhotoUrl =
        isParticipantOne ? participantTwoPhotoUrl : participantOnePhotoUrl;

    return ChatConversation(
      id: id,
      participantOneId: participantOneId,
      participantTwoId: participantTwoId,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      name: otherName,
      avatarUrl: otherPhotoUrl,
      lastMessage: lastMessageContent ?? '',
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount,
      lastMessageIsMine: false,
      lastMessageStatus: MessageStatus.sent,
    );
  }
}

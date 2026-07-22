import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';

class CreateConversationUseCase {
  final ChatRepository _repository;

  CreateConversationUseCase(this._repository);

  Future<ChatConversation> execute({
    required String otherUserId,
    required String otherUserRole,
    String? propertyId,
    String? propertyTitle,
    String? requesterName,
    String? requesterPhotoUrl,
    String? otherUserName,
    String? otherUserPhotoUrl,
  }) =>
      _repository.createConversation(
        otherUserId: otherUserId,
        otherUserRole: otherUserRole,
        propertyId: propertyId,
        propertyTitle: propertyTitle,
        requesterName: requesterName,
        requesterPhotoUrl: requesterPhotoUrl,
        otherUserName: otherUserName,
        otherUserPhotoUrl: otherUserPhotoUrl,
      );
}

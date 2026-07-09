import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';

class GetConversationsUseCase {
  final ChatRepository _repository;

  GetConversationsUseCase(this._repository);

  Future<List<ChatConversation>> execute() => _repository.getConversations();
}

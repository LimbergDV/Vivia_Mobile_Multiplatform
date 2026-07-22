import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';

class JoinConversationUseCase {
  final ChatRepository _repository;

  JoinConversationUseCase(this._repository);

  void execute(String conversationId) =>
      _repository.joinConversation(conversationId);
}

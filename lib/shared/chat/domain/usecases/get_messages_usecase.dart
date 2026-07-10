import 'package:vivia_mobile/shared/chat/domain/models/chat_message.dart';
import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository _repository;

  GetMessagesUseCase(this._repository);

  Future<List<ChatMessage>> execute(String conversationId) =>
      _repository.getMessages(conversationId);
}

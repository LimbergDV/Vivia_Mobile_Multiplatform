import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';

class SendTypingUseCase {
  final ChatRepository _repository;

  SendTypingUseCase(this._repository);

  void execute(String conversationId) => _repository.sendTyping(conversationId);
}

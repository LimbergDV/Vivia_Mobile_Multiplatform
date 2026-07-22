import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  void execute(String conversationId, String content, {required String localId}) =>
      _repository.sendMessage(conversationId, content, localId: localId);
}

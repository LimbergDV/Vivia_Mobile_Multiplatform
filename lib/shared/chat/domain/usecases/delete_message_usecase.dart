import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';

class DeleteMessageUseCase {
  final ChatRepository _repository;

  DeleteMessageUseCase(this._repository);

  void execute(String messageId) => _repository.deleteMessage(messageId);
}

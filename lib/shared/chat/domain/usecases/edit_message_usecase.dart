import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';

class EditMessageUseCase {
  final ChatRepository _repository;

  EditMessageUseCase(this._repository);

  void execute(String messageId, String content) =>
      _repository.editMessage(messageId, content);
}

import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';

class MarkReadUseCase {
  final ChatRepository _repository;

  MarkReadUseCase(this._repository);

  void execute(String conversationId) => _repository.markRead(conversationId);
}

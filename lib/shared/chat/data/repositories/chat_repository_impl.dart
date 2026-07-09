import 'package:vivia_mobile/shared/chat/data/datasources/local/chat_mock_datasource.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_message.dart';
import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatMockDatasource _local;

  ChatRepositoryImpl({required ChatMockDatasource local}) : _local = local;

  @override
  Future<List<ChatConversation>> getConversations() =>
      _local.getConversations();

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) =>
      _local.getMessages(conversationId);
}

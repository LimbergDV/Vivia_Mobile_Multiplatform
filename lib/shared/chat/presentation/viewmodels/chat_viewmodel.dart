import 'package:flutter/foundation.dart';
import 'package:vivia_mobile/shared/chat/domain/enums/message_status.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_message.dart';
import 'package:vivia_mobile/shared/chat/domain/usecases/get_messages_usecase.dart';

class ChatViewModel extends ChangeNotifier {
  final String conversationId;
  final GetMessagesUseCase _getMessagesUseCase;

  ChatViewModel({
    required this.conversationId,
    required GetMessagesUseCase getMessagesUseCase,
  }) : _getMessagesUseCase = getMessagesUseCase;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _messages = await _getMessagesUseCase.execute(conversationId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void sendMessage(String text) {
    final value = text.trim();
    if (value.isEmpty) return;
    _messages = [..._messages, _buildOutgoing(value)];
    notifyListeners();
  }

  ChatMessage _buildOutgoing(String text) => ChatMessage(
        id: 'local_${DateTime.now().microsecondsSinceEpoch}',
        text: text,
        sentAt: DateTime.now(),
        isMine: true,
        status: MessageStatus.sent,
      );
}

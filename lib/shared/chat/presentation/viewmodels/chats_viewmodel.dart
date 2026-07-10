import 'package:flutter/foundation.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/domain/usecases/get_conversations_usecase.dart';

class ChatsViewModel extends ChangeNotifier {
  final GetConversationsUseCase _getConversationsUseCase;

  ChatsViewModel({required GetConversationsUseCase getConversationsUseCase})
      : _getConversationsUseCase = getConversationsUseCase;

  List<ChatConversation> _conversations = [];
  bool _isLoading = false;
  String? _error;

  List<ChatConversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => !_isLoading && _error == null && _conversations.isEmpty;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _conversations = await _getConversationsUseCase.execute();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

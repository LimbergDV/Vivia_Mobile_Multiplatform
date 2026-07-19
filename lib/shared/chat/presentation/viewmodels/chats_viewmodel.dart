import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';
import 'package:vivia_mobile/shared/chat/domain/usecases/get_conversations_usecase.dart';

class ChatsViewModel extends ChangeNotifier {
  final GetConversationsUseCase _getConversationsUseCase;
  final ChatRepository _repository;

  ChatsViewModel({
    required GetConversationsUseCase getConversationsUseCase,
    required ChatRepository repository,
  })  : _getConversationsUseCase = getConversationsUseCase,
        _repository = repository;

  List<ChatConversation> _conversations = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  List<ChatConversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => !_isLoading && _error == null && _conversations.isEmpty;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.connectWebSocket();
      _conversations = await _getConversationsUseCase.execute();
      _subscribeToWs();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToWs() {
    _wsSub?.cancel();
    _wsSub = _repository.wsEvents.listen((envelope) {
      final event = envelope['event'] as String?;
      final payload = envelope['payload'] as Map<String, dynamic>?;
      if (event == 'newMessage' && payload != null) {
        _onNewMessage(payload);
      }
    });
  }

  void _onNewMessage(Map<String, dynamic> payload) {
    final conversationId = payload['conversationId'] as String?;
    if (conversationId == null) return;

    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;

    final old = _conversations[idx];
    final updated = ChatConversation(
      id: old.id,
      name: old.name,
      participantOneId: old.participantOneId,
      participantTwoId: old.participantTwoId,
      propertyId: old.propertyId,
      propertyTitle: old.propertyTitle,
      avatarUrl: old.avatarUrl,
      lastMessage: payload['content'] as String? ?? old.lastMessage,
      lastMessageAt: payload['createdAt'] != null
          ? DateTime.parse(payload['createdAt'] as String).toLocal()
          : old.lastMessageAt,
      unreadCount: old.unreadCount + 1,
      lastMessageIsMine: false,
      lastMessageStatus: old.lastMessageStatus,
    );

    final updatedList = List<ChatConversation>.from(_conversations);
    updatedList[idx] = updated;
    // Mueve la conversación con nuevo mensaje al tope
    updatedList.insert(0, updatedList.removeAt(idx));
    _conversations = updatedList;
    notifyListeners();
  }

  void deleteConversation(String conversationId) {
    _conversations = _conversations.where((c) => c.id != conversationId).toList();
    notifyListeners();
    _repository.deleteConversation(conversationId);
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }
}

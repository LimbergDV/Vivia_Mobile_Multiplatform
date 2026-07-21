import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vivia_mobile/shared/chat/domain/enums/message_status.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_message.dart';
import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';
import 'package:vivia_mobile/shared/chat/domain/usecases/get_messages_usecase.dart';
import 'package:vivia_mobile/shared/chat/data/models/message_model.dart';
import 'package:vivia_mobile/features/auth/data/datasources/local/auth_local_datasource.dart';

class ChatViewModel extends ChangeNotifier {
  static String? activeConversationId;

  final String conversationId;
  final GetMessagesUseCase _getMessagesUseCase;
  final ChatRepository _repository;
  final AuthLocalDatasource _local;

  final String? _autoMessage;

  ChatViewModel({
    required this.conversationId,
    required GetMessagesUseCase getMessagesUseCase,
    required ChatRepository repository,
    required AuthLocalDatasource local,
    String? autoMessage,
  })  : _getMessagesUseCase = getMessagesUseCase,
        _repository = repository,
        _local = local,
        _autoMessage = autoMessage;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isTyping = false;
  String? _error;
  String? _wsError;
  String? _editingMessageId;
  String? _editingInitialText;
  StreamSubscription<Map<String, dynamic>>? _wsSub;
  Timer? _typingTimer;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isTyping => _isTyping;
  String? get error => _error;
  String? get wsError => _wsError;
  String? get editingMessageId => _editingMessageId;
  String? get editingInitialText => _editingInitialText;

  String get _currentUserId => _local.getUserId() ?? '';

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    activeConversationId = conversationId;
    notifyListeners();
    try {
      await _repository.connectWebSocket();
      final msgs = await _getMessagesUseCase.execute(conversationId);
      _messages = msgs.reversed.toList(); // más recientes al final
      _hasMore = msgs.length == 50;
      _repository.joinConversation(conversationId);
      _subscribeToWs();
      if (_autoMessage != null) {
        sendMessage(_autoMessage);
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _messages.isEmpty) return;
    final oldest = _messages.first;
    try {
      final older = await _getMessagesUseCase.execute(
        conversationId,
        before: oldest.sentAt.toIso8601String(),
      );
      final reversed = older.reversed.toList();
      _messages = [...reversed, ..._messages];
      _hasMore = older.length == 50;
      notifyListeners();
    } catch (_) {}
  }

  void sendMessage(String text) {
    final value = text.trim();
    if (value.isEmpty) return;
    _repository.sendMessage(conversationId, value);
    // Mensaje optimista mientras el servidor lo confirma
    _messages = [
      ..._messages,
      ChatMessage(
        id: 'local_${DateTime.now().microsecondsSinceEpoch}',
        senderId: _currentUserId,
        text: value,
        sentAt: DateTime.now(),
        isMine: true,
        status: MessageStatus.sent,
      ),
    ];
    notifyListeners();
  }

  void notifyTyping() {
    _repository.sendTyping(conversationId);
  }

  void deleteMessage(String messageId) {
    _repository.deleteMessage(messageId);
  }

  void startEditing(ChatMessage message) {
    _editingMessageId = message.id;
    _editingInitialText = message.text;
    notifyListeners();
  }

  void cancelEditing() {
    _editingMessageId = null;
    _editingInitialText = null;
    notifyListeners();
  }

  void editMessage(String newContent) {
    final id = _editingMessageId;
    if (id == null) return;
    final value = newContent.trim();
    if (value.isEmpty) return;
    _repository.editMessage(id, value);
    _editingMessageId = null;
    _editingInitialText = null;
    notifyListeners();
  }

  void clearWsError() {
    _wsError = null;
  }

  void _subscribeToWs() {
    _wsSub?.cancel();
    _wsSub = _repository.wsEvents.listen((envelope) {
      final event = envelope['event'] as String?;
      final payload = envelope['payload'] as Map<String, dynamic>?;
      if (payload == null) return;

      final convId = payload['conversationId'] as String?;

      switch (event) {
        case 'joined':
          if (convId == conversationId) {
            _repository.markRead(conversationId);
          }
        case 'newMessage':
          if (convId == conversationId) _handleNewMessage(payload);
        case 'typing':
          if (convId == conversationId) _handleTyping();
        case 'messagesRead':
          if (convId == conversationId) _handleMessagesRead();
        case 'messageDeleted':
          if (convId == conversationId) _handleMessageDeleted(payload);
        case 'messageEdited':
          if (convId == conversationId) _handleMessageEdited(payload);
        case 'error':
          final reason = payload['reason'] as String?;
          if (reason != null) {
            _wsError = reason;
            notifyListeners();
          }
      }
    });
  }

  void _handleNewMessage(Map<String, dynamic> payload) {
    final incoming = MessageModel.fromJson(payload).toDomain(_currentUserId);
    // Si el mensaje es mío, reemplaza el primer optimista pendiente (FIFO)
    if (incoming.isMine) {
      final optIdx = _messages.indexWhere((m) => m.id.startsWith('local_'));
      if (optIdx != -1) {
        final updated = List<ChatMessage>.from(_messages);
        updated[optIdx] = incoming;
        _messages = updated;
        notifyListeners();
        return;
      }
    }
    _messages = [..._messages, incoming];
    // Si recibo un mensaje del otro mientras estoy en el chat, marco como leído
    if (!incoming.isMine) {
      _repository.markRead(conversationId);
    }
    notifyListeners();
  }

  void _handleTyping() {
    _isTyping = true;
    notifyListeners();
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      _isTyping = false;
      notifyListeners();
    });
  }

  void _handleMessagesRead() {
    _messages = _messages.map((m) {
      if (m.isMine && m.status != MessageStatus.read) {
        return m.copyWith(status: MessageStatus.read);
      }
      return m;
    }).toList();
    notifyListeners();
  }

  void _handleMessageDeleted(Map<String, dynamic> payload) {
    final messageId = payload['messageId'] as String?;
    final hardDeleted = payload['hardDeleted'] as bool? ?? false;
    if (messageId == null) return;

    if (hardDeleted) {
      _messages = _messages.where((m) => m.id != messageId).toList();
    } else {
      // Soft-delete: servidor manda el objeto actualizado con deletedAt y content null
      final messageJson = payload['message'] as Map<String, dynamic>?;
      _messages = _messages.map((m) {
        if (m.id != messageId) return m;
        if (messageJson != null) {
          return MessageModel.fromJson(messageJson).toDomain(_currentUserId);
        }
        return m.copyWith(deletedAt: DateTime.now(), text: '');
      }).toList();
    }
    notifyListeners();
  }

  void _handleMessageEdited(Map<String, dynamic> payload) {
    final updated = MessageModel.fromJson(payload).toDomain(_currentUserId);
    _messages = _messages.map((m) => m.id == updated.id ? updated : m).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    activeConversationId = null;
    _wsSub?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:vivia_mobile/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:vivia_mobile/shared/chat/data/datasources/remote/constants/chat_api_constants.dart';

typedef VoidCallback = void Function();

abstract class ChatWebSocketDatasource {
  Stream<Map<String, dynamic>> get events;
  void send(String event, Map<String, dynamic> payload);
  void sendMessage(String localId, Map<String, dynamic> payload);
  void acknowledgeMessage(String localId);
  void retryMessage(String localId);
  bool get isConnected;
  Future<void> connect();
  void disconnect();
  void registerJoinedConversation(String conversationId);
  void unregisterJoinedConversation(String conversationId);
}

class _PendingMessage {
  final String localId;
  final Map<String, dynamic> payload;

  _PendingMessage({required this.localId, required this.payload});
}

class ChatWebSocketDatasourceImpl implements ChatWebSocketDatasource {
  final AuthLocalDatasource _local;
  final VoidCallback _onSessionExpired;

  ChatWebSocketDatasourceImpl(this._local, this._onSessionExpired);

  io.WebSocket? _ws;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  final Set<String> _joinedConversations = {};
  final List<_PendingMessage> _pendingQueue = [];
  bool _intentionalClose = false;
  Completer<void>? _connectCompleter;
  int _retryDelay = 3;
  Timer? _reconnectTimer;

  @override
  Stream<Map<String, dynamic>> get events => _controller.stream;

  @override
  bool get isConnected => _ws != null && _ws!.readyState == io.WebSocket.open;

  @override
  Future<void> connect() async {
    final jwt = _local.getAccessToken();
    if (jwt == null) return;
    if (isConnected) return;
    if (_connectCompleter != null) {
      await _connectCompleter!.future;
      return;
    }
    _intentionalClose = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _connectCompleter = Completer<void>();
    try {
      await _doConnect(jwt);
    } finally {
      _connectCompleter?.complete();
      _connectCompleter = null;
    }
  }

  Future<void> _doConnect(String jwt) async {
    try {
      final oldWs = _ws;
      _ws = null;
      oldWs?.close().catchError((_) {});

      _ws = await io.WebSocket.connect(
        ChatApiConstants.wsUrl,
        headers: {'Authorization': 'Bearer $jwt'},
      );

      _ws!.listen(
        (data) {
          try {
            final envelope =
                jsonDecode(data as String) as Map<String, dynamic>;
            _controller.add(envelope);
          } catch (_) {}
        },
        onDone: () {
          final code = _ws?.closeCode;
          _ws = null;
          if (_intentionalClose) return;
          if (code == 4001) {
            _onSessionExpired();
            return;
          }
          _scheduleReconnect();
        },
        onError: (_) {
          _ws = null;
          if (!_intentionalClose) _scheduleReconnect();
        },
      );

      _retryDelay = 3;
      _rejoinAll();
    } catch (_) {
      _ws = null;
      if (!_intentionalClose) _scheduleReconnect();
    }
  }

  void _rejoinAll() {
    for (final id in _joinedConversations) {
      send('joinConversation', {'conversationId': id});
    }
    if (_pendingQueue.isNotEmpty) {
      Future.delayed(const Duration(seconds: 1), _flushQueue);
    }
  }

  void _flushQueue() {
    if (!isConnected || _pendingQueue.isEmpty) return;
    for (final msg in _pendingQueue) {
      _ws!.add(jsonEncode({
        'event': 'newMessage',
        'payload': msg.payload,
      }));
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _retryDelay), () {
      if (_intentionalClose) return;
      _retryDelay = (_retryDelay * 2).clamp(3, 60);
      connect();
    });
  }

  @override
  void disconnect() {
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _joinedConversations.clear();
    _pendingQueue.clear();
    _ws?.close().catchError((_) {});
    _ws = null;
  }

  @override
  void registerJoinedConversation(String conversationId) {
    _joinedConversations.add(conversationId);
  }

  @override
  void unregisterJoinedConversation(String conversationId) {
    _joinedConversations.remove(conversationId);
  }

  @override
  void send(String event, Map<String, dynamic> payload) {
    if (!isConnected) return;
    _ws!.add(jsonEncode({'event': event, 'payload': payload}));
  }

  @override
  void sendMessage(String localId, Map<String, dynamic> payload) {
    _pendingQueue.add(_PendingMessage(localId: localId, payload: payload));
    if (isConnected) {
      _ws!.add(jsonEncode({'event': 'newMessage', 'payload': payload}));
    }
  }

  @override
  void acknowledgeMessage(String localId) {
    _pendingQueue.removeWhere((m) => m.localId == localId);
  }

  @override
  void retryMessage(String localId) {
    final msg = _pendingQueue.cast<_PendingMessage?>().firstWhere(
          (m) => m!.localId == localId,
          orElse: () => null,
        );
    if (msg == null) return;
    if (isConnected) {
      _ws!.add(jsonEncode({'event': 'newMessage', 'payload': msg.payload}));
    }
  }
}

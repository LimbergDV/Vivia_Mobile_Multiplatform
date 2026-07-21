import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:vivia_mobile/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:vivia_mobile/shared/chat/data/datasources/remote/constants/chat_api_constants.dart';

typedef VoidCallback = void Function();

abstract class ChatWebSocketDatasource {
  Stream<Map<String, dynamic>> get events;
  void send(String event, Map<String, dynamic> payload);
  Future<void> connect();
  void disconnect();
  void registerJoinedConversation(String conversationId);
  void unregisterJoinedConversation(String conversationId);
}

class ChatWebSocketDatasourceImpl implements ChatWebSocketDatasource {
  final AuthLocalDatasource _local;
  final VoidCallback _onSessionExpired;

  ChatWebSocketDatasourceImpl(this._local, this._onSessionExpired);

  io.WebSocket? _ws;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  final Set<String> _joinedConversations = {};
  bool _intentionalClose = false;
  int _retryDelay = 3;

  @override
  Stream<Map<String, dynamic>> get events => _controller.stream;

  @override
  Future<void> connect() async {
    final jwt = _local.getAccessToken();
    if (jwt == null) return;
    // Idempotente: si ya está abierto no abre una segunda conexión
    if (_ws != null && _ws!.readyState == io.WebSocket.open) return;
    _intentionalClose = false;
    await _doConnect(jwt);
  }

  Future<void> _doConnect(String jwt) async {
    try {
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
          if (_intentionalClose) return;
          final code = _ws?.closeCode;
          if (code == 4001) {
            _onSessionExpired();
            return;
          }
          _scheduleReconnect();
        },
        onError: (_) {
          if (!_intentionalClose) _scheduleReconnect();
        },
      );

      _retryDelay = 3;
      _rejoinAll();
    } catch (_) {
      if (!_intentionalClose) _scheduleReconnect();
    }
  }

  void _rejoinAll() {
    for (final id in _joinedConversations) {
      send('joinConversation', {'conversationId': id});
    }
  }

  void _scheduleReconnect() {
    Future.delayed(Duration(seconds: _retryDelay), () {
      if (_intentionalClose) return;
      _retryDelay = (_retryDelay * 2).clamp(3, 60);
      connect();
    });
  }

  @override
  void disconnect() {
    _intentionalClose = true;
    _joinedConversations.clear();
    _ws?.close();
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
    if (_ws == null || _ws!.readyState != io.WebSocket.open) return;
    _ws!.add(jsonEncode({'event': event, 'payload': payload}));
  }
}

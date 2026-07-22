import 'package:flutter/material.dart';
import 'package:vivia_mobile/shared/chat/domain/enums/message_status.dart';

class ChatReadCheck extends StatelessWidget {
  final MessageStatus status;
  final double size;

  const ChatReadCheck({super.key, required this.status, this.size = 16});

  static const _readColor = Color(0xFF4C8DF6);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.pending:
        return Icon(Icons.access_time, size: size,
            color: Theme.of(context).colorScheme.outline);
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: size,
            color: Colors.red.shade400);
      case MessageStatus.sent:
      case MessageStatus.delivered:
        return _doubleCheck(Theme.of(context).colorScheme.outline);
      case MessageStatus.read:
        return _doubleCheck(_readColor);
    }
  }

  Widget _doubleCheck(Color color) {
    return SizedBox(
      width: size + 6,
      height: size,
      child: Stack(
        children: [
          Icon(Icons.done, size: size, color: color),
          Positioned(
            left: 6,
            child: Icon(Icons.done, size: size, color: color),
          ),
        ],
      ),
    );
  }
}

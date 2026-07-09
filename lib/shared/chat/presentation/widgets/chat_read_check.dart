import 'package:flutter/material.dart';
import 'package:vivia_mobile/shared/chat/domain/enums/message_status.dart';

class ChatReadCheck extends StatelessWidget {
  final MessageStatus status;
  final double size;

  const ChatReadCheck({super.key, required this.status, this.size = 16});

  static const _readColor = Color(0xFF4C8DF6);

  @override
  Widget build(BuildContext context) {
    final color =
        status.isRead ? _readColor : Theme.of(context).colorScheme.outline;
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

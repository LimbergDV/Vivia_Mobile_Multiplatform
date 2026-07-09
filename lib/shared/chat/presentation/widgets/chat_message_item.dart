import 'package:flutter/material.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_message.dart';
import 'package:vivia_mobile/shared/chat/presentation/helpers/chat_time_formatter.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/chat_bubble.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatMessage message;
  final bool showLabel;
  final bool isLastOverall;

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.showLabel,
    required this.isLastOverall,
  });

  @override
  Widget build(BuildContext context) {
    final align =
        message.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final maxWidth = MediaQuery.of(context).size.width * 0.74;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          ChatBubble(
            text: message.text,
            isMine: message.isMine,
            maxWidth: maxWidth.clamp(0, 460),
          ),
          if (showLabel) _Label(message: message, isLastOverall: isLastOverall),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final ChatMessage message;
  final bool isLastOverall;

  const _Label({required this.message, required this.isLastOverall});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final showRead = isLastOverall && message.status.isRead;
    final time = ChatTimeFormatter.format(message.sentAt, upperMeridiem: true);
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
      child: Text(
        showRead ? 'Leído   $time' : time,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

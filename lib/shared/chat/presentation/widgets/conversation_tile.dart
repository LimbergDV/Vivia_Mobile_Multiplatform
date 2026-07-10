import 'package:flutter/material.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/presentation/helpers/chat_time_formatter.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/chat_avatar.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/chat_read_check.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/unread_badge.dart';

class ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                ChatAvatar(
                  name: conversation.name,
                  avatarUrl: conversation.avatarUrl,
                  size: 54,
                ),
                const SizedBox(width: 14),
                Expanded(child: _Content(conversation: conversation)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ChatConversation conversation;

  const _Content({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                conversation.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              ChatTimeFormatter.format(conversation.lastMessageAt),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _Preview(conversation: conversation),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  final ChatConversation conversation;

  const _Preview({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        if (conversation.lastMessageIsMine) ...[
          ChatReadCheck(status: conversation.lastMessageStatus),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            conversation.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: conversation.hasUnread
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
              fontWeight:
                  conversation.hasUnread ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        if (conversation.hasUnread) ...[
          const SizedBox(width: 8),
          UnreadBadge(count: conversation.unreadCount),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/presentation/viewmodels/chats_viewmodel.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/chats_skeleton_list.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/conversation_tile.dart';

class ChatsContent extends StatelessWidget {
  final ValueChanged<ChatConversation> onOpenConversation;

  const ChatsContent({super.key, required this.onOpenConversation});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatsViewModel>();
    if (vm.isLoading) return const ChatsSkeletonList();
    if (vm.error != null && vm.conversations.isEmpty) {
      return _ErrorView(message: vm.error!);
    }
    return _ChatsList(
      conversations: vm.conversations,
      onOpenConversation: onOpenConversation,
    );
  }
}

class _ChatsList extends StatelessWidget {
  final List<ChatConversation> conversations;
  final ValueChanged<ChatConversation> onOpenConversation;

  const _ChatsList({
    required this.conversations,
    required this.onOpenConversation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: conversations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => ConversationTile(
            conversation: conversations[i],
            onTap: () => onOpenConversation(conversations[i]),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: context.read<ChatsViewModel>().load,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

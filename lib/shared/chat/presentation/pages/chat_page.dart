import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/domain/usecases/get_messages_usecase.dart';
import 'package:vivia_mobile/shared/chat/presentation/viewmodels/chat_viewmodel.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/chat_input_bar.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/chat_messages_view.dart';

class ChatPage extends StatelessWidget {
  final ChatConversation conversation;

  const ChatPage({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ChatViewModel(
        conversationId: conversation.id,
        getMessagesUseCase: ctx.read<GetMessagesUseCase>(),
      )..load(),
      child: _ChatView(title: conversation.name),
    );
  }
}

class _ChatView extends StatelessWidget {
  final String title;

  const _ChatView({required this.title});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Adjuntar archivos estará disponible pronto'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: _ChatAppBar(title: title),
      body: Column(
        children: [
          const Expanded(child: ChatMessagesView()),
          ChatInputBar(
            onSend: context.read<ChatViewModel>().sendMessage,
            onAttach: () => _showComingSoon(context),
          ),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const _ChatAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

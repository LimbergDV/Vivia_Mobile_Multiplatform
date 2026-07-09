import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:vivia_mobile/shared/chat/presentation/pages/chat_page.dart';
import 'package:vivia_mobile/shared/chat/presentation/viewmodels/chats_viewmodel.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/chats_content.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ChatsViewModel(
        getConversationsUseCase: ctx.read<GetConversationsUseCase>(),
      )..load(),
      child: const _ChatsView(),
    );
  }
}

class _ChatsView extends StatelessWidget {
  const _ChatsView();

  void _openConversation(BuildContext context, ChatConversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatPage(conversation: conversation)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: const _ChatsAppBar(),
      body: SafeArea(
        top: false,
        child: ChatsContent(
          onOpenConversation: (c) => _openConversation(context, c),
        ),
      ),
    );
  }
}

class _ChatsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatsAppBar();

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
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Chats',
        style: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_conversation.dart';
import 'package:vivia_mobile/shared/chat/domain/repositories/chat_repository.dart';
import 'package:vivia_mobile/shared/chat/domain/usecases/get_messages_usecase.dart';
import 'package:vivia_mobile/shared/chat/presentation/viewmodels/chat_viewmodel.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/chat_input_bar.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/chat_messages_view.dart';
import 'package:vivia_mobile/features/premium/presentation/widgets/premium_required_dialog.dart';
import 'package:vivia_mobile/shared/widgets/app_alert.dart';

class ChatPage extends StatelessWidget {
  final ChatConversation conversation;
  final String? autoMessage;

  const ChatPage({
    super.key,
    required this.conversation,
    this.autoMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ChatViewModel(
        conversationId: conversation.id,
        getMessagesUseCase: ctx.read<GetMessagesUseCase>(),
        repository: ctx.read<ChatRepository>(),
        local: ctx.read<AuthLocalDatasource>(),
        autoMessage: autoMessage,
      )..load(),
      child: _ChatView(title: conversation.name),
    );
  }
}

class _ChatView extends StatelessWidget {
  final String title;

  const _ChatView({required this.title});

  void _showComingSoon(BuildContext context) {
    AppAlert.show(context, message: 'Adjuntar archivos estará disponible pronto');
  }

  /// El lessor free superó el límite de conversaciones al responder: ofrecemos
  /// Premium y, si se suscribe, reintentamos el mensaje sin salir del chat.
  Future<void> _handlePremiumBlock(BuildContext context, ChatViewModel vm) async {
    final message = vm.premiumRequiredMessage!;
    vm.clearPremiumRequired();
    final becamePremium =
        await PremiumRequiredDialog.show(context, message: message);
    if (becamePremium && context.mounted) {
      vm.retryBlockedMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    if (vm.premiumRequiredMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) _handlePremiumBlock(context, vm);
      });
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: _ChatAppBar(title: title),
      body: Column(
        children: [
          const Expanded(child: ChatMessagesView()),
          Consumer<ChatViewModel>(
            builder: (ctx, vm, _) => ChatInputBar(
              onSend: vm.editingMessageId != null ? vm.editMessage : vm.sendMessage,
              onAttach: () => _showComingSoon(ctx),
              editingText: vm.editingInitialText,
              onCancelEdit: vm.editingMessageId != null ? vm.cancelEditing : null,
            ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_message.dart';
import 'package:vivia_mobile/shared/chat/presentation/viewmodels/chat_viewmodel.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/chat_message_item.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/property_context_card.dart';

class ChatMessagesView extends StatefulWidget {
  final Map<String, dynamic>? propertyContext;

  const ChatMessagesView({super.key, this.propertyContext});

  @override
  State<ChatMessagesView> createState() => _ChatMessagesViewState();
}

class _ChatMessagesViewState extends State<ChatMessagesView> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  bool _isLastInRun(List<ChatMessage> items, int i) =>
      i == items.length - 1 || items[i + 1].isMine != items[i].isMine;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    if (vm.wsError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.wsError!),
            behavior: SnackBarBehavior.floating,
          ),
        );
        vm.clearWsError();
      });
    }

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    _scrollToBottom();
    final ctx = widget.propertyContext;
    final hasCtx = ctx != null;
    final itemCount = vm.messages.length + (hasCtx ? 1 : 0);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView.builder(
          controller: _controller,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: itemCount,
          itemBuilder: (_, i) {
            if (hasCtx && i == 0) {
              return PropertyContextCard(ctx: ctx);
            }
            final msgIndex = hasCtx ? i - 1 : i;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ChatMessageItem(
                message: vm.messages[msgIndex],
                showLabel: _isLastInRun(vm.messages, msgIndex),
                isLastOverall: msgIndex == vm.messages.length - 1,
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_message.dart';
import 'package:vivia_mobile/shared/chat/presentation/viewmodels/chat_viewmodel.dart';
import 'package:vivia_mobile/shared/chat/presentation/widgets/chat_message_item.dart';

class ChatMessagesView extends StatefulWidget {
  const ChatMessagesView({super.key});

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
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    _scrollToBottom();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView.builder(
          controller: _controller,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          itemCount: vm.messages.length,
          itemBuilder: (_, i) => ChatMessageItem(
            message: vm.messages[i],
            showLabel: _isLastInRun(vm.messages, i),
            isLastOverall: i == vm.messages.length - 1,
          ),
        ),
      ),
    );
  }
}

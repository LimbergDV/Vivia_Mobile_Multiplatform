import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback? onAttach;

  const ChatInputBar({super.key, required this.onSend, this.onAttach});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  static const _accent = Color(0xFF5B8DF0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSend(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _Field(controller: _controller, onAttach: widget.onAttach)),
            const SizedBox(width: 8),
            _SendButton(
              controller: _controller,
              color: _accent,
              onSend: _handleSend,
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onAttach;

  const _Field({required this.controller, required this.onAttach});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(26),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: onAttach,
            icon: Icon(Icons.add_rounded,
                color: colorScheme.onSurfaceVariant, size: 26),
          ),
          Expanded(child: _TextField(controller: controller)),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;

  const _TextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: 5,
      cursorColor: colorScheme.primary,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: 'Comenzar a escribir',
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final TextEditingController controller;
  final Color color;
  final VoidCallback onSend;

  const _SendButton({
    required this.controller,
    required this.color,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;
        return GestureDetector(
          onTap: hasText ? onSend : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasText ? color : color.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
          ),
        );
      },
    );
  }
}

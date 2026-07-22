import 'package:flutter/material.dart';
import 'package:vivia_mobile/core/utils/input_sanitizer.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback? onAttach;
  /// Texto del mensaje que se está editando. Null → modo "enviar nuevo".
  final String? editingText;
  final VoidCallback? onCancelEdit;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onAttach,
    this.editingText,
    this.onCancelEdit,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const _accent = Color(0xFF5B8DF0);

  bool get _isEditing => widget.editingText != null;

  @override
  void didUpdateWidget(ChatInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasEditing = oldWidget.editingText != null;
    final nowEditing = widget.editingText != null;

    if (nowEditing && widget.editingText != oldWidget.editingText) {
      // Entró en modo edición (o cambió el mensaje que se edita)
      _controller.text = widget.editingText!;
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
      _focusNode.requestFocus();
    } else if (!nowEditing && wasEditing) {
      // Canceló la edición
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final message = InputSanitizer.multiLine(_controller.text);
    if (message.isEmpty) return;
    widget.onSend(message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isEditing) _EditBanner(onCancel: widget.onCancelEdit),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _Field(
                      controller: _controller,
                      focusNode: _focusNode,
                      onAttach: _isEditing ? null : widget.onAttach,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SendButton(
                    controller: _controller,
                    color: _accent,
                    isEditing: _isEditing,
                    onSend: _handleSend,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditBanner extends StatelessWidget {
  final VoidCallback? onCancel;

  const _EditBanner({this.onCancel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const accent = Color(0xFF5B8DF0);
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
        color: colorScheme.surface,
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        children: [
          const Icon(Icons.edit_outlined, size: 16, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Editando mensaje',
              style: TextStyle(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onCancel,
            icon: Icon(Icons.close_rounded, size: 20, color: colorScheme.onSurfaceVariant),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onAttach;

  const _Field({
    required this.controller,
    required this.focusNode,
    required this.onAttach,
  });

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
            icon: Icon(
              Icons.add_rounded,
              color: onAttach != null
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurfaceVariant.withOpacity(0.3),
              size: 26,
            ),
          ),
          Expanded(child: _TextField(controller: controller, focusNode: focusNode)),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _TextField({required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      minLines: 1,
      maxLines: 5,
      maxLength: 1000,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
          null,
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
  final bool isEditing;
  final VoidCallback onSend;

  const _SendButton({
    required this.controller,
    required this.color,
    required this.isEditing,
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
            child: Icon(
              isEditing ? Icons.check_rounded : Icons.send_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        );
      },
    );
  }
}

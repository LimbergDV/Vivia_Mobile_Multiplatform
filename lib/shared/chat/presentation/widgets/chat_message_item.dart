import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/shared/chat/domain/enums/message_status.dart';
import 'package:vivia_mobile/shared/chat/domain/models/chat_message.dart';
import 'package:vivia_mobile/shared/chat/presentation/helpers/chat_time_formatter.dart';
import 'package:vivia_mobile/shared/chat/presentation/viewmodels/chat_viewmodel.dart';
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
    final isLocal = message.id.startsWith('local_');
    final now = DateTime.now();
    final canDel = !isLocal && message.canDelete(now);
    final canEdt = !isLocal && message.canEdit(now);
    final hasMenu = canDel || canEdt;
    final isFailed = message.status.isFailed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          GestureDetector(
            onLongPress: hasMenu ? () => _showContextMenu(context, canDel, canEdt) : null,
            onTap: isFailed
                ? () => context.read<ChatViewModel>().retryMessage(message.id)
                : null,
            child: ChatBubble(
              text: message.text,
              isMine: message.isMine,
              isDeleted: message.isDeleted,
              maxWidth: maxWidth.clamp(0, 460),
              status: message.status,
            ),
          ),
          if (showLabel || isFailed)
            _Label(message: message, isLastOverall: isLastOverall),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context, bool canDel, bool canEdt) {
    final vm = context.read<ChatViewModel>();
    final renderBox = context.findRenderObject()! as RenderBox;
    final topLeft = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;

    showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: true,
      barrierLabel: 'Cerrar menú',
      transitionDuration: Duration.zero,
      pageBuilder: (dlgCtx, _, __) {
        final cs = Theme.of(dlgCtx).colorScheme;

        Widget iconBtn({
          required IconData icon,
          required Color color,
          required VoidCallback onTap,
          required String label,
        }) =>
            Semantics(
              label: label,
              button: true,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(icon, size: 21, color: color),
                ),
              ),
            );

        return Stack(
          children: [
            Positioned(
              top: topLeft.dy - 58,
              left: message.isMine ? null : topLeft.dx,
              right: message.isMine
                  ? screenWidth - topLeft.dx - size.width
                  : null,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: cs.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canEdt) ...[
                        iconBtn(
                          icon: Icons.edit_outlined,
                          color: cs.onSurface,
                          label: 'Editar mensaje',
                          onTap: () {
                            Navigator.pop(dlgCtx);
                            vm.startEditing(message);
                          },
                        ),
                        if (canDel)
                          Container(width: 0.5, height: 24, color: cs.outlineVariant),
                      ],
                      if (canDel)
                        iconBtn(
                          icon: Icons.delete_outline,
                          color: Colors.red.shade400,
                          label: 'Eliminar mensaje',
                          onTap: () {
                            Navigator.pop(dlgCtx);
                            vm.deleteMessage(message.id);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
    final time = ChatTimeFormatter.format(message.sentAt, upperMeridiem: true);
    final labelStyle = textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    if (message.status.isFailed) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 13, color: Colors.red.shade400),
            const SizedBox(width: 4),
            Text(
              'Error al enviar. Toca para reintentar',
              style: labelStyle?.copyWith(color: Colors.red.shade400),
            ),
          ],
        ),
      );
    }

    if (message.status.isPending) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 13, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(time, style: labelStyle),
          ],
        ),
      );
    }

    final showRead = isLastOverall && message.status.isRead;
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.isEdited) ...[
            Text(
              '(editado)',
              style: labelStyle?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(width: 4),
          ],
          Text(showRead ? 'Leído   $time' : time, style: labelStyle),
        ],
      ),
    );
  }
}

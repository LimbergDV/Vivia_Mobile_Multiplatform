import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMine;
  final double maxWidth;
  final bool isDeleted;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMine,
    required this.maxWidth,
    this.isDeleted = false,
  });

  static const _mineColor = Color(0xFF5B8DF0);
  static const _radius = Radius.circular(20);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: isMine ? _mineColor : colorScheme.surface,
          borderRadius: _borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isMine ? 0.10 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isDeleted
            ? Text(
                'Mensaje eliminado',
                style: textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: isMine
                      ? Colors.white.withOpacity(0.65)
                      : colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              )
            : Text(
                text,
                style: textTheme.bodyMedium?.copyWith(
                  color: isMine ? Colors.white : colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
      ),
    );
  }

  BorderRadius get _borderRadius => BorderRadius.only(
        topLeft: _radius,
        topRight: _radius,
        bottomLeft: isMine ? _radius : const Radius.circular(6),
        bottomRight: isMine ? const Radius.circular(6) : _radius,
      );
}

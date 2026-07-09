import 'package:flutter/material.dart';

class ChatAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;

  const ChatAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Initials(name: name),
              )
            : _Initials(name: name),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String name;

  const _Initials({required this.name});

  String get _letters {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.primaryContainer,
      child: Center(
        child: Text(
          _letters,
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ChatsSkeletonList extends StatelessWidget {
  const ChatsSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const _SkeletonTile(),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _Circle(color: colorScheme.surfaceContainerHighest),
          const SizedBox(width: 12),
          Expanded(child: _Lines(color: colorScheme.surfaceContainerHighest)),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final Color color;

  const _Circle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Lines extends StatelessWidget {
  final Color color;

  const _Lines({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Bar(color: color, width: 150),
        const SizedBox(height: 10),
        _Bar(color: color, width: double.infinity),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final Color color;
  final double width;

  const _Bar({required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

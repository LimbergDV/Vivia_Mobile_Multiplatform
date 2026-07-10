import 'package:flutter/material.dart';

class NotificationsEmptyState extends StatelessWidget {
  final String title;

  const NotificationsEmptyState({
    super.key,
    this.title = 'Parece que aún no tienes\nnotificaciones',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final side = MediaQuery.of(context).size.shortestSide * 0.32;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _EmptyIcon(side: side.clamp(96.0, 160.0)),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyIcon extends StatelessWidget {
  final double side;

  const _EmptyIcon({required this.side});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: side * 1.15,
      height: side * 1.15,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          _NoteShape(side: side),
          Positioned(top: 0, right: side * 0.06, child: _RedDot(size: side * 0.24)),
        ],
      ),
    );
  }
}

class _NoteShape extends StatelessWidget {
  final double side;

  const _NoteShape({required this.side});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: const Color(0xFF9AA6AD),
        borderRadius: BorderRadius.circular(side * 0.24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Line(width: side * 0.5, side: side),
          SizedBox(height: side * 0.12),
          _Line(width: side * 0.3, side: side),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final double width;
  final double side;

  const _Line({required this.width, required this.side});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: side * 0.2),
      child: Container(
        width: width,
        height: side * 0.08,
        decoration: BoxDecoration(
          color: const Color(0xFF12303F),
          borderRadius: BorderRadius.circular(side),
        ),
      ),
    );
  }
}

class _RedDot extends StatelessWidget {
  final double size;

  const _RedDot({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE24C4B),
        shape: BoxShape.circle,
      ),
    );
  }
}

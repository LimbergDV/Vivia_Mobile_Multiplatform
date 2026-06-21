import 'package:flutter/material.dart';

class PropertyImageCell extends StatelessWidget {
  final String imagePath;
  final double borderRadius;

  const PropertyImageCell({
    super.key,
    required this.imagePath,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox.expand(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) return child;
            return _ShimmerPlaceholder(colorScheme: colorScheme);
          },
          errorBuilder: (context, error, stackTrace) {
            return _ErrorPlaceholder(colorScheme: colorScheme);
          },
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  final ColorScheme colorScheme;
  const _ShimmerPlaceholder({required this.colorScheme});

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => ColoredBox(
        color: widget.colorScheme.surfaceContainerHighest
            .withOpacity(_animation.value),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;
  const _ErrorPlaceholder({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colorScheme.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.home_outlined,
          color: colorScheme.onSurfaceVariant.withOpacity(0.4),
          size: 24,
        ),
      ),
    );
  }
}
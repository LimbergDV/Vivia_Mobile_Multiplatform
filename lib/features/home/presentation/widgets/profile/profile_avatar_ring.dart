import 'dart:math';
import 'package:flutter/material.dart';

class ProfileAvatarRing extends StatelessWidget {
  final String? avatarUrl;
  final double progress;
  final double size;

  const ProfileAvatarRing({
    super.key,
    this.avatarUrl,
    required this.progress,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const ringColor = Color(0xFF0095FF);
    const strokeWidth = 4.5;
    const gap = 5.0;
    final avatarRadius = (size / 2) - strokeWidth - gap;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          ringColor: ringColor,
          trackColor: colorScheme.outlineVariant.withOpacity(0.25),
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage:
            avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(
              Icons.person,
              size: avatarRadius * 0.85,
              color: colorScheme.primary,
            )
                : null,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
          old.ringColor != ringColor ||
          old.strokeWidth != strokeWidth;
}
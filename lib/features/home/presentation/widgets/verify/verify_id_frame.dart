import 'package:flutter/material.dart';

class VerifyIdFrame extends StatelessWidget {
  final Widget child;
  final bool showCameraIcon;

  const VerifyIdFrame({
    super.key,
    required this.child,
    this.showCameraIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: const _DashedBorderPainter(),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: child,
            ),
          ),
        ),
        if (showCameraIcon)
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF0095FF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0095FF)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const dashWidth = 9.0;
    const dashSpace = 5.0;
    const radius = Radius.circular(16);

    final path = Path()
      ..addRRect(RRect.fromLTRBR(0, 0, size.width, size.height, radius));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter _) => false;
}
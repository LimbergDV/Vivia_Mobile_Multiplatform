import 'package:flutter/material.dart';

class DashedUploadZone extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const DashedUploadZone({
    super.key,
    this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(color: colorScheme.outlineVariant),
        child: Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: imagePath != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 42,
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              ),
              const SizedBox(height: 4),
              Icon(
                Icons.upload_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              ),
              const SizedBox(height: 10),
              Text(
                'Explorar archivos desde su teléfono',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 5.0;
    const radius = 12.0;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
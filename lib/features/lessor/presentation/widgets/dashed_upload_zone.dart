import 'dart:io';

import 'package:flutter/material.dart';

class DashedUploadZone extends StatelessWidget {
  final String? imagePath;
  final bool isVideo;
  final VoidCallback onTap;

  const DashedUploadZone({
    super.key,
    this.imagePath,
    this.isVideo = false,
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
                  child: isVideo
                      ? _VideoSelectedIndicator(
                          fileName: imagePath!.split('/').last,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        )
                      : Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) =>
                              _ErrorPlaceholder(colorScheme: colorScheme),
                        ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isVideo ? Icons.videocam_outlined : Icons.image_outlined,
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

class _VideoSelectedIndicator extends StatelessWidget {
  final String fileName;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _VideoSelectedIndicator({
    required this.fileName,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_rounded, size: 48, color: colorScheme.primary),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              fileName,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;

  const _ErrorPlaceholder({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 42,
          color: colorScheme.onSurfaceVariant.withOpacity(0.4),
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

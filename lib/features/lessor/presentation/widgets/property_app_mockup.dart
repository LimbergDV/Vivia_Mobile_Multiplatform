import 'package:flutter/material.dart';

class PropertyAppMockup extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String category;
  final String price;
  final String description;

  const PropertyAppMockup({
    super.key,
    this.imageUrl,
    required this.title,
    required this.category,
    required this.price,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini status bar simulada
          Container(
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '9:41',
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.signal_cellular_alt,
                        size: 7, color: colorScheme.onSurface),
                    const SizedBox(width: 2),
                    Icon(Icons.wifi, size: 7, color: colorScheme.onSurface),
                    const SizedBox(width: 2),
                    Icon(Icons.battery_full,
                        size: 7, color: colorScheme.onSurface),
                  ],
                ),
              ],
            ),
          ),

          // Mini AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 10, color: colorScheme.onSurface),
                Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 10, color: colorScheme.onSurface),
                    const SizedBox(width: 4),
                    Icon(Icons.favorite_border_rounded,
                        size: 10, color: colorScheme.onSurface),
                    const SizedBox(width: 4),
                    Icon(Icons.send_outlined,
                        size: 10, color: colorScheme.onSurface),
                  ],
                ),
              ],
            ),
          ),

          // Imagen
          ClipRRect(
            child: SizedBox(
              height: 90,
              width: double.infinity,
              child: imageUrl != null
                  ? Image.asset(imageUrl!, fit: BoxFit.cover)
                  : Container(color: colorScheme.surfaceContainerHigh),
            ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    fontSize: 8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0095FF).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF0095FF),
                      fontSize: 5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    fontSize: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _MiniStat(label: '8 Beds', colorScheme: colorScheme),
                    const SizedBox(width: 6),
                    _MiniStat(label: '3 bath', colorScheme: colorScheme),
                    const SizedBox(width: 6),
                    _MiniStat(label: '2000 sqft', colorScheme: colorScheme),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Overview',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    fontSize: 7,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 6,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final ColorScheme colorScheme;

  const _MiniStat({required this.label, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.square_foot,
            size: 6, color: const Color(0xFF0095FF)),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 5.5,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
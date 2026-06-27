import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vivia_mobile/features/home/domain/models/property_model.dart';

class PropertyPreviewCard extends StatelessWidget {
  final PropertyModel property;

  const PropertyPreviewCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: property.imageUrl.isNotEmpty
                  ? Image.network(
                property.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _Placeholder(colorScheme: colorScheme),
              )
                  : _Placeholder(colorScheme: colorScheme),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.type,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${_formatPrice(property.price)}',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0061FF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Stat(
                      svgPath: 'assets/images/icons/ic_area.svg',
                      label: '${property.area.toInt()}m²',
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(width: 6),
                    _Stat(
                      svgPath: 'assets/images/icons/ic_bed.svg',
                      label: '${property.bedrooms}',
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(width: 6),
                    _Stat(
                      svgPath: 'assets/images/icons/ic_bath.svg',
                      label: '${property.bathrooms}',
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]},',
    );
  }
}

class _Placeholder extends StatelessWidget {
  final ColorScheme colorScheme;
  const _Placeholder({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHigh,
      child: Icon(
        Icons.home_outlined,
        size: 36,
        color: colorScheme.onSurfaceVariant.withOpacity(0.3),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String svgPath;
  final String label;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _Stat({
    required this.svgPath,
    required this.label,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(svgPath, width: 13, height: 13),
        const SizedBox(width: 3),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
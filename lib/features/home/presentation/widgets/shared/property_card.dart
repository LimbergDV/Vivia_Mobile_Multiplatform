import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vivia_mobile/features/home/domain/models/property_model.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onTap;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              child: AspectRatio(
                aspectRatio: 1.1,
                child: Image.network(
                  property.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: colorScheme.surfaceContainerHigh,
                    child: Icon(
                      Icons.home_outlined,
                      size: 40,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      property.type,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    Text(
                      '\$${_formatPrice(property.price)}',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF04364A),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        _PropertyStat(
                          svgPath: 'assets/icons/area_icon.svg',
                          label: '${property.area.toInt()}m²',
                          textTheme: textTheme,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(width: 8),
                        _PropertyStat(
                          svgPath: 'assets/icons/bath_icon.svg',
                          label: '${property.bedrooms}',
                          textTheme: textTheme,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(width: 8),
                        _PropertyStat(
                          svgPath: 'assets/icons/bed_icon.svg',
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

class _PropertyStat extends StatelessWidget {
  final String svgPath;
  final String label;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _PropertyStat({
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
        SvgPicture.asset(
          svgPath,
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
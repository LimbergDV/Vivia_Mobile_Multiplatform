import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_model.dart';

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
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.shortestSide >= 600;
    final isLandscape = mq.orientation == Orientation.landscape;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
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
            Expanded(
              flex: 3,
              child: _CardImage(
                imageUrl: property.imageUrl,
                colorScheme: colorScheme,
              ),
            ),
            Expanded(
              flex: 2,
              child: _PropertyInfo(
                property: property,
                isTablet: isTablet,
                isLandscape: isLandscape,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  final String imageUrl;
  final ColorScheme colorScheme;

  const _CardImage({required this.imageUrl, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: SizedBox.expand(
        child: Image.network(
          imageUrl,
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
    );
  }
}

class _PropertyInfo extends StatelessWidget {
  final PropertyModel property;
  final bool isTablet;
  final bool isLandscape;

  const _PropertyInfo({
    required this.property,
    required this.isTablet,
    required this.isLandscape,
  });

  MainAxisAlignment get _alignment {
    if (isLandscape) return MainAxisAlignment.center;
    return isTablet
        ? MainAxisAlignment.spaceEvenly
        : MainAxisAlignment.spaceBetween;
  }

  EdgeInsets get _padding => isTablet
      ? const EdgeInsets.fromLTRB(12, 10, 12, 8)
      : const EdgeInsets.fromLTRB(8, 6, 8, 4);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final gap =
        isLandscape ? const SizedBox(height: 14) : const SizedBox.shrink();

    return Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: _alignment,
        children: [
          _title(textTheme, colorScheme),
          gap,
          _price(textTheme),
          gap,
          _stats(textTheme, colorScheme),
        ],
      ),
    );
  }

  Widget _title(TextTheme textTheme, ColorScheme colorScheme) {
    final base = isTablet ? textTheme.titleMedium : textTheme.bodyMedium;
    return Text(
      property.title,
      style: base?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: isTablet ? 18 : 15,
        color: colorScheme.onSurface,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _price(TextTheme textTheme) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        '\$${_formatPrice(property.price)}',
        style: (isTablet ? textTheme.titleLarge : textTheme.titleSmall)
            ?.copyWith(
          fontWeight: FontWeight.w800,
          color: const Color(0xFF04364A),
        ),
      ),
    );
  }

  Widget _stats(TextTheme textTheme, ColorScheme colorScheme) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        children: [
          _PropertyStat(
            svgPath: 'assets/icons/area_icon.svg',
            label: '${property.area.toInt()}m²',
            textTheme: textTheme,
            colorScheme: colorScheme,
            isTablet: isTablet,
          ),
          SizedBox(width: isTablet ? 14 : 8),
          _PropertyStat(
            svgPath: 'assets/icons/bed_icon.svg',
            label: '${property.bedrooms}',
            textTheme: textTheme,
            colorScheme: colorScheme,
            isTablet: isTablet,
          ),
          SizedBox(width: isTablet ? 14 : 8),
          _PropertyStat(
            svgPath: 'assets/icons/bath_icon.svg',
            label: _formatBathrooms(property.bathrooms),
            textTheme: textTheme,
            colorScheme: colorScheme,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  // Muestra "2" en vez de "2.0", pero conserva "2.5" para medios baños
  String _formatBathrooms(double bathrooms) =>
      bathrooms == bathrooms.truncateToDouble()
          ? bathrooms.toInt().toString()
          : bathrooms.toString();

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
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
  final bool isTablet;

  const _PropertyStat({
    required this.svgPath,
    required this.label,
    required this.textTheme,
    required this.colorScheme,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isTablet ? 26.0 : 19.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          svgPath,
          width: iconSize,
          height: iconSize,
        ),
        SizedBox(width: isTablet ? 6 : 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 17 : 14,
          ),
        ),
      ],
    );
  }
}

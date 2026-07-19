import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/home/presentation/pages/property_detail_page.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/property_viewmodel.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_model.dart';

class PropertyContextCard extends StatelessWidget {
  final Map<String, dynamic> ctx;

  const PropertyContextCard({super.key, required this.ctx});

  String _formatPrice(double price) =>
      '\$${price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      )}';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final title = ctx['title'] as String? ?? '';
    final type = ctx['type'] as String? ?? '';
    final price = (ctx['price'] as num?)?.toDouble() ?? 0;
    final isRent = ctx['isRent'] as bool? ?? false;
    final neighborhood = ctx['neighborhood'] as String? ?? '';
    final priceSuffix = isRent ? ' / mes' : '';
    final formattedPrice = '${_formatPrice(price)}$priceSuffix';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversación sobre',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Pill(icon: Icons.attach_money_rounded, label: formattedPrice),
                    const SizedBox(width: 8),
                    if (neighborhood.isNotEmpty)
                      _Pill(icon: Icons.location_on_outlined, label: neighborhood),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: colorScheme.outlineVariant),
          InkWell(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            onTap: () => _navigateToProperty(context, type),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Ver propiedad',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                      size: 15, color: colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToProperty(BuildContext context, String type) {
    final property = PropertyModel(
      id: ctx['propertyId'] as String? ?? '',
      title: ctx['title'] as String? ?? '',
      type: type,
      price: (ctx['price'] as num?)?.toDouble() ?? 0,
      location: ctx['location'] as String? ?? '',
      area: (ctx['area'] as num?)?.toDouble() ?? 0,
      bedrooms: (ctx['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (ctx['bathrooms'] as num?)?.toDouble() ?? 0,
      imageUrl: '',
    );

    final isLessor = context.read<PropertyViewModel>().isLessor;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailPage(
          property: property,
          role: isLessor ? UserRole.lessor : UserRole.lessee,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

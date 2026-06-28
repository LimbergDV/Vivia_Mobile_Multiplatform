import 'package:flutter/material.dart';

enum PropertyListingType { venta, renta }

class PropertyTypeToggle extends StatelessWidget {
  final PropertyListingType selected;
  final ValueChanged<PropertyListingType> onChanged;

  const PropertyTypeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Venta',
            isSelected: selected == PropertyListingType.venta,
            onTap: () => onChanged(PropertyListingType.venta),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          _ToggleOption(
            label: 'Renta',
            isSelected: selected == PropertyListingType.renta,
            onTap: () => onChanged(PropertyListingType.renta),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: double.infinity,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0095FF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: const Color(0xFF0095FF).withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? Colors.white
                  : colorScheme.onSurfaceVariant,
              fontWeight:
              isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
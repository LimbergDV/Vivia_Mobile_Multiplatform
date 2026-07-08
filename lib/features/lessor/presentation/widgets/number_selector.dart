import 'package:flutter/material.dart';

class NumberSelector extends StatelessWidget {
  final int? selected;
  final List<String> options;
  final ValueChanged<int> onSelected;

  const NumberSelector({
    super.key,
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final double chipSize = isLandscape
        ? (screenWidth - 64 - (8 * 6)) / 7
        : (screenWidth - 40 - (8 * 8)) / 9;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(options.length, (i) {
        final isSelected = selected == i;
        return GestureDetector(
          onTap: () => onSelected(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: chipSize.clamp(40.0, 60.0),
            height: chipSize.clamp(40.0, 60.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF0095FF)
                  : colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0095FF)
                    : colorScheme.outlineVariant,
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              options[i],
              style: textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vivia_mobile/shared/property/domain/models/selected_category.dart';

class CategoryChipList extends StatelessWidget {
  final List<SelectedCategory> categories;
  final SelectedCategory selected;
  final ValueChanged<SelectedCategory> onSelected;

  const CategoryChipList({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  bool _isSelected(SelectedCategory a, SelectedCategory b) {
    if (a is AllCategory && b is AllCategory) return true;
    if (a is FavoritesCategory && b is FavoritesCategory) return true;
    if (a is TypeCategory && b is TypeCategory) return a.type.id == b.type.id;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final category = categories[i];
          return _CategoryChip(
            label: category.label,
            isSelected: _isSelected(category, selected),
            onTap: () => onSelected(category),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    const selectedColor = Color(0xFF0095FF);
    const unselectedBorderColor = Color(0xFF0061FF);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor
              : unselectedBorderColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : unselectedBorderColor.withOpacity(0.04),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

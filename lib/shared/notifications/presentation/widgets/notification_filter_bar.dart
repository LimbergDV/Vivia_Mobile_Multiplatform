import 'package:flutter/material.dart';
import 'package:vivia_mobile/shared/notifications/domain/enums/notification_filter.dart';

class NotificationFilterBar extends StatelessWidget {
  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onSelected;

  const NotificationFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: NotificationFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final filter = NotificationFilter.values[i];
          return _FilterChip(
            label: filter.label,
            isSelected: filter == selected,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const _selectedColor = Color(0xFF0095FF);
  static const _borderColor = Color(0xFF0061FF);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _selectedColor : _borderColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? _selectedColor : _borderColor.withOpacity(0.08),
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

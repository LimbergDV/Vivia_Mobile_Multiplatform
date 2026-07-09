import 'package:flutter/material.dart';

class ProfileSettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showNotificationDot;
  final bool isDestructive;

  const ProfileSettingsItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.showNotificationDot = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final itemColor =
    isDestructive ? colorScheme.error : colorScheme.onSurface;
    final iconColor =
    isDestructive ? colorScheme.error : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      splashColor:
      (isDestructive ? colorScheme.error : colorScheme.primary)
          .withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  color: itemColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showNotificationDot)
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(right: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3B30),
                  shape: BoxShape.circle,
                ),
              ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant.withOpacity(0.55),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
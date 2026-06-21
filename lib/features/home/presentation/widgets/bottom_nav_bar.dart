import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum HomeNavItem { home, notifications, add, messages, profile }

class HomeBottomNavBar extends StatelessWidget {
  final HomeNavItem selected;
  final ValueChanged<HomeNavItem> onItemSelected;

  const HomeBottomNavBar({
    super.key,
    required this.selected,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIcon(
            assetPath: 'assets/icons/home_icon.svg',
            isSelected: selected == HomeNavItem.home,
            onTap: () => onItemSelected(HomeNavItem.home),
          ),
          _NavIcon(
            assetPath: 'assets/icons/notification_icon.svg',
            isSelected: selected == HomeNavItem.notifications,
            onTap: () => onItemSelected(HomeNavItem.notifications),
          ),

          GestureDetector(
            onTap: () => onItemSelected(HomeNavItem.add),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.onSurface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                color: colorScheme.surface,
                size: 28,
              ),
            ),
          ),

          _NavIcon(
            assetPath: 'assets/icons/chat_icon.svg',
            isSelected: selected == HomeNavItem.messages,
            onTap: () => onItemSelected(HomeNavItem.messages),
          ),
          _NavIcon(
            assetPath: 'assets/icons/profile_icon.svg',
            isSelected: selected == HomeNavItem.profile,
            onTap: () => onItemSelected(HomeNavItem.profile),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIcon({
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant.withOpacity(0.6);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset(
          assetPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }
}
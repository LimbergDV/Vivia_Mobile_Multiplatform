import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum HomeNavItem { home, notifications, add, messages, profile }

class HomeBottomNavBar extends StatelessWidget {
  final HomeNavItem selected;
  final ValueChanged<HomeNavItem> onItemSelected;
  final bool showAddButton;

  const HomeBottomNavBar({
    super.key,
    required this.selected,
    required this.onItemSelected,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 72,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEFEFEF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _NavItem(
                    assetPath: 'assets/icons/home_icon.svg',
                    isSelected: selected == HomeNavItem.home,
                    onTap: () => onItemSelected(HomeNavItem.home),
                  ),
                  _NavItem(
                    assetPath: 'assets/icons/notification_icon.svg',
                    isSelected: selected == HomeNavItem.notifications,
                    onTap: () => onItemSelected(HomeNavItem.notifications),
                  ),
                  const SizedBox(width: 58),
                  _NavItem(
                    assetPath: 'assets/icons/chat_icon.svg',
                    isSelected: selected == HomeNavItem.messages,
                    onTap: () => onItemSelected(HomeNavItem.messages),
                  ),
                  _NavItem(
                    assetPath: 'assets/icons/profile_icon.svg',
                    isSelected: selected == HomeNavItem.profile,
                    onTap: () => onItemSelected(HomeNavItem.profile),
                  ),
                ],
              ),
            ),
          ),

          if (showAddButton)
            Positioned(
              bottom: 22,
              child: GestureDetector(
                onTap: () => onItemSelected(HomeNavItem.add),
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF04364A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF04364A).withOpacity(0.35),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF04364A).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  const HomeHeader({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola!',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                userName,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: onNotificationTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SvgPicture.asset(
                'assets/icons/notification_icon.svg',
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(
                  colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              if (notificationCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),

        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: avatarUrl != null
                  ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _AvatarFallback(colorScheme: colorScheme),
              )
                  : _AvatarFallback(colorScheme: colorScheme),
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final ColorScheme colorScheme;
  const _AvatarFallback({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.primaryContainer,
      child: Icon(
        Icons.person_outline,
        color: colorScheme.onPrimaryContainer,
        size: 22,
      ),
    );
  }
}
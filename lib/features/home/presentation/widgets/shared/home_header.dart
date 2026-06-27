import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/user/presentation/viewmodels/user_viewmodel.dart';

class HomeHeader extends StatelessWidget {
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  const HomeHeader({
    super.key,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, vm, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final hasData = vm.displayName.isNotEmpty;

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
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: hasData
                        ? Text(
                            vm.displayName,
                            key: ValueKey(vm.displayName),
                            style: textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : _SkeletonBox(
                            key: const ValueKey('name_skeleton'),
                            width: 130,
                            height: 30,
                            colorScheme: colorScheme,
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
                  Icon(
                    Icons.notifications_outlined,
                    size: 28,
                    color: colorScheme.onSurface,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: hasData
                  ? GestureDetector(
                      key: const ValueKey('avatar'),
                      onTap: onAvatarTap,
                      child: _AvatarWidget(
                        avatarUrl: vm.avatarUrl,
                        colorScheme: colorScheme,
                      ),
                    )
                  : _SkeletonCircle(
                      key: const ValueKey('avatar_skeleton'),
                      size: 44,
                      colorScheme: colorScheme,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final ColorScheme colorScheme;

  const _SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  final double size;
  final ColorScheme colorScheme;

  const _SkeletonCircle({
    super.key,
    required this.size,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final ColorScheme colorScheme;

  const _AvatarWidget({
    required this.avatarUrl,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _AvatarFallback(colorScheme: colorScheme),
              )
            : _AvatarFallback(colorScheme: colorScheme),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final ColorScheme colorScheme;
  const _AvatarFallback({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.person_outline_rounded,
      color: colorScheme.onPrimaryContainer,
      size: 24,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vivia_mobile/shared/notifications/domain/enums/notification_type.dart';

class NotificationTypeBadge extends StatelessWidget {
  final NotificationType type;
  final double size;

  const NotificationTypeBadge({
    super.key,
    required this.type,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(type);
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(style.icon, color: style.color, size: size * 0.5),
    );
  }

  _BadgeStyle _styleFor(NotificationType type) => switch (type) {
        NotificationType.publication =>
          const _BadgeStyle(Icons.home_work_rounded, Color(0xFF3BA776)),
        NotificationType.system =>
          const _BadgeStyle(Icons.settings_suggest_rounded, Color(0xFFE8A33D)),
        NotificationType.message =>
          const _BadgeStyle(Icons.person_rounded, Color(0xFF9B6B9E)),
        NotificationType.general =>
          const _BadgeStyle(Icons.notifications_rounded, Color(0xFF0095FF)),
      };
}

class _BadgeStyle {
  final IconData icon;
  final Color color;

  const _BadgeStyle(this.icon, this.color);
}

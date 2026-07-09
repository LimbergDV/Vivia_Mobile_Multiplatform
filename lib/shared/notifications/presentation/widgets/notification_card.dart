import 'package:flutter/material.dart';
import 'package:vivia_mobile/shared/notifications/domain/models/notification_model.dart';
import 'package:vivia_mobile/shared/notifications/presentation/helpers/notification_date_formatter.dart';
import 'package:vivia_mobile/shared/notifications/presentation/widgets/notification_type_badge.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  static const _cardColor = Color(0xFF12303F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NotificationTypeBadge(type: notification.type),
          const SizedBox(width: 14),
          Expanded(child: _CardBody(notification: notification)),
        ],
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  final NotificationModel notification;

  const _CardBody({required this.notification});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          NotificationDateFormatter.format(notification.createdAt),
          style: textTheme.bodySmall?.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 8),
        Text(
          notification.body,
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

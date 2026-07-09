import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vivia_mobile/shared/notifications/domain/enums/notification_type.dart';
import 'package:vivia_mobile/shared/notifications/domain/models/notification_model.dart';

class NotificationMessageMapper {
  NotificationMessageMapper._();

  static NotificationModel toModel(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    return NotificationModel(
      id: message.messageId ?? data['id']?.toString() ?? _fallbackId(),
      type: NotificationType.fromApi(
        data['type']?.toString() ?? data['category']?.toString(),
      ),
      title: notification?.title ?? data['title']?.toString() ?? 'Notificación',
      body: notification?.body ??
          data['body']?.toString() ??
          data['message']?.toString() ??
          '',
      createdAt: DateTime.now(),
      isRead: false,
    );
  }

  static String _fallbackId() =>
      DateTime.now().microsecondsSinceEpoch.toString();
}

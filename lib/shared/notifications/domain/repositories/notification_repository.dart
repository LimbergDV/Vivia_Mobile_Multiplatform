import 'package:vivia_mobile/shared/notifications/domain/models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> save(NotificationModel notification);
  Future<int> unreadCount();
  Future<void> markAllRead();
}

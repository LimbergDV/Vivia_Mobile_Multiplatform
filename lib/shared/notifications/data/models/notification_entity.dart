import 'package:vivia_mobile/shared/notifications/data/datasources/local/notification_table.dart';
import 'package:vivia_mobile/shared/notifications/domain/enums/notification_type.dart';
import 'package:vivia_mobile/shared/notifications/domain/models/notification_model.dart';

class NotificationEntity {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationEntity.fromModel(NotificationModel model, String userId) =>
      NotificationEntity(
        id: model.id,
        userId: userId,
        type: model.type.name,
        title: model.title,
        body: model.body,
        createdAt: model.createdAt.toIso8601String(),
        isRead: model.isRead,
      );

  factory NotificationEntity.fromMap(Map<String, Object?> map) =>
      NotificationEntity(
        id: map[NotificationTable.id] as String,
        userId: map[NotificationTable.userId] as String,
        type: map[NotificationTable.type] as String,
        title: map[NotificationTable.title] as String,
        body: map[NotificationTable.body] as String,
        createdAt: map[NotificationTable.createdAt] as String,
        isRead: (map[NotificationTable.isRead] as int? ?? 0) == 1,
      );

  Map<String, Object?> toMap() => {
        NotificationTable.id: id,
        NotificationTable.userId: userId,
        NotificationTable.type: type,
        NotificationTable.title: title,
        NotificationTable.body: body,
        NotificationTable.createdAt: createdAt,
        NotificationTable.isRead: isRead ? 1 : 0,
      };

  NotificationModel toModel() => NotificationModel(
        id: id,
        type: NotificationType.fromApi(type),
        title: title,
        body: body,
        createdAt: DateTime.tryParse(createdAt)?.toLocal() ?? DateTime.now(),
        isRead: isRead,
      );
}

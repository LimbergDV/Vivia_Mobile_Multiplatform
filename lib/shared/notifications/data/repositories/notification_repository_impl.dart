import 'package:vivia_mobile/shared/notifications/data/datasources/local/notification_local_datasource.dart';
import 'package:vivia_mobile/shared/notifications/data/models/notification_entity.dart';
import 'package:vivia_mobile/shared/notifications/domain/models/notification_model.dart';
import 'package:vivia_mobile/shared/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDatasource _local;
  final String? Function() _getUserId;

  NotificationRepositoryImpl({
    required NotificationLocalDatasource local,
    required String? Function() getUserId,
  })  : _local = local,
        _getUserId = getUserId;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final userId = _getUserId();
    if (userId == null) return [];
    final entities = await _local.getByUser(userId);
    return entities.map((e) => e.toModel()).toList();
  }

  @override
  Future<void> save(NotificationModel notification) async {
    final userId = _getUserId();
    if (userId == null) return;
    await _local.insert(NotificationEntity.fromModel(notification, userId));
  }

  @override
  Future<int> unreadCount() async {
    final userId = _getUserId();
    if (userId == null) return 0;
    return _local.unreadCount(userId);
  }

  @override
  Future<void> markAllRead() async {
    final userId = _getUserId();
    if (userId == null) return;
    await _local.markAllRead(userId);
  }
}

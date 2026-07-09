import 'package:vivia_mobile/shared/notifications/domain/models/notification_model.dart';
import 'package:vivia_mobile/shared/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<List<NotificationModel>> execute() => _repository.getNotifications();
}

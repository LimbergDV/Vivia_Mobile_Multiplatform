import 'package:vivia_mobile/shared/notifications/domain/models/notification_model.dart';
import 'package:vivia_mobile/shared/notifications/domain/repositories/notification_repository.dart';

class SaveNotificationUseCase {
  final NotificationRepository _repository;

  SaveNotificationUseCase(this._repository);

  Future<void> execute(NotificationModel notification) =>
      _repository.save(notification);
}

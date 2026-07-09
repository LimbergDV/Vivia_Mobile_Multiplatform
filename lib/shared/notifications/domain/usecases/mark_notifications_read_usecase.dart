import 'package:vivia_mobile/shared/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationsReadUseCase {
  final NotificationRepository _repository;

  MarkNotificationsReadUseCase(this._repository);

  Future<void> execute() => _repository.markAllRead();
}

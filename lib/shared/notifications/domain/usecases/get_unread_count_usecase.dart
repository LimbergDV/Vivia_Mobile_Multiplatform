import 'package:vivia_mobile/shared/notifications/domain/repositories/notification_repository.dart';

class GetUnreadCountUseCase {
  final NotificationRepository _repository;

  GetUnreadCountUseCase(this._repository);

  Future<int> execute() => _repository.unreadCount();
}

import 'package:flutter/foundation.dart';
import 'package:vivia_mobile/shared/notifications/domain/enums/notification_filter.dart';
import 'package:vivia_mobile/shared/notifications/domain/enums/notification_type.dart';
import 'package:vivia_mobile/shared/notifications/domain/models/notification_model.dart';
import 'package:vivia_mobile/shared/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:vivia_mobile/shared/notifications/domain/usecases/mark_notifications_read_usecase.dart';

class NotificationsViewModel extends ChangeNotifier {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationsReadUseCase _markReadUseCase;

  NotificationsViewModel({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationsReadUseCase markReadUseCase,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _markReadUseCase = markReadUseCase;

  List<NotificationModel> _all = [];
  NotificationFilter _filter = NotificationFilter.all;
  bool _isLoading = false;
  String? _error;

  NotificationFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<NotificationModel> get notifications {
    if (_filter == NotificationFilter.all) return _all;
    return _all.where(_matches).toList();
  }

  bool get isEmpty => !_isLoading && _error == null && notifications.isEmpty;

  bool _matches(NotificationModel n) => switch (_filter) {
        NotificationFilter.messages => n.type == NotificationType.message,
        NotificationFilter.publications => n.type == NotificationType.publication,
        NotificationFilter.system => n.type == NotificationType.system,
        NotificationFilter.all => true,
      };

  void selectFilter(NotificationFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _all = await _getNotificationsUseCase.execute();
      await _markReadUseCase.execute();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

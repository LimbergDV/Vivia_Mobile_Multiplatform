import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vivia_mobile/features/user/domain/repositories/user_repository.dart';

class RegisterFcmTokenUseCase {
  final UserRepository _repository;

  RegisterFcmTokenUseCase(this._repository);

  Future<void> execute() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _repository.updateFcmToken(token);
    } catch (_) {
      // No bloquear el flujo de login si el registro del token falla
    }
  }
}

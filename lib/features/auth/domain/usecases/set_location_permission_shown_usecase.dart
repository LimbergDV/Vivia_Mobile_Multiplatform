import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';

class SetLocationPermissionShownUseCase {
  final AuthRepository _repository;

  SetLocationPermissionShownUseCase(this._repository);

  Future<void> execute() => _repository.setLocationPermissionShown();
}

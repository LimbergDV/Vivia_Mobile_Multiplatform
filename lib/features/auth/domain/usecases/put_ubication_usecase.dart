import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';

class PutUbicationUseCase {
  final AuthRepository _repository;

  PutUbicationUseCase(this._repository);

  Future<void> execute({required double latitude, required double longitude}) =>
      _repository.putUbication(latitude: latitude, longitude: longitude);
}

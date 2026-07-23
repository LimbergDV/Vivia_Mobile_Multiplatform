import 'package:vivia_mobile/features/lessor/publishing/domain/repositories/lessor_repository.dart';

/// Pre-check `GET /properties/posts`: completa si el lessor puede publicar,
/// o lanza [PremiumRequiredException] (402) si alcanzó el límite gratuito.
class CheckCanPublishUseCase {
  final LessorRepository _repository;
  const CheckCanPublishUseCase(this._repository);

  Future<void> execute() => _repository.checkCanPublish();
}

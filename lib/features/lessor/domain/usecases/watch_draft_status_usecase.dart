import 'package:vivia_mobile/features/lessor/domain/models/draft_status_event.dart';
import 'package:vivia_mobile/features/lessor/domain/repositories/lessor_repository.dart';

class WatchDraftStatusUseCase {
  final LessorRepository _repository;
  WatchDraftStatusUseCase(this._repository);

  Stream<DraftStatusEvent> execute(String draftId) =>
      _repository.watchDraftStatus(draftId);
}

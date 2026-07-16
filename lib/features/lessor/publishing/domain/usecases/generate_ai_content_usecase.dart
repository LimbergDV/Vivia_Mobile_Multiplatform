import 'package:vivia_mobile/features/lessor/publishing/domain/models/ai_content_event.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/repositories/lessor_repository.dart';

class GenerateAiContentUseCase {
  final LessorRepository _repository;
  const GenerateAiContentUseCase(this._repository);

  Stream<AiContentEvent> execute(Map<String, dynamic> draft) =>
      _repository.generateAiContent(draft);
}

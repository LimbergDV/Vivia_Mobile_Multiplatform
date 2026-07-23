import 'package:vivia_mobile/features/lessor/publishing/data/models/amenity_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/draft_upload_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/ai_content_event.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/draft_status_event.dart';

abstract class LessorRepository {
  Future<List<NeighborhoodModel>> getNeighborhoods(String cp);
  Future<List<AmenityModel>> getAmenities();
  Future<void> checkCanPublish();
  Future<DraftUploadModel> createDraft(Map<String, dynamic> body);
  Future<void> uploadFile(
    String uploadUrl,
    String contentType,
    List<int> bytes,
  );
  Stream<DraftStatusEvent> watchDraftStatus(String draftId);
  Stream<AiContentEvent> generateAiContent(Map<String, dynamic> draft);
}

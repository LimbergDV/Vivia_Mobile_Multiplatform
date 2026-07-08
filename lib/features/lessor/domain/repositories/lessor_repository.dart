import 'package:vivia_mobile/features/lessor/data/models/amenity_model.dart';
import 'package:vivia_mobile/features/lessor/data/models/draft_upload_model.dart';
import 'package:vivia_mobile/features/lessor/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/domain/models/draft_status_event.dart';

abstract class LessorRepository {
  Future<List<NeighborhoodModel>> getNeighborhoods(String cp);
  Future<List<AmenityModel>> getAmenities();
  Future<DraftUploadModel> createDraft(Map<String, dynamic> body);
  Future<void> uploadFile(
    String uploadUrl,
    String contentType,
    List<int> bytes,
  );
  Stream<DraftStatusEvent> watchDraftStatus(String draftId);
}

import 'package:vivia_mobile/features/lessor/publishing/data/datasources/remote/lessor_remote_datasource.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/amenity_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/draft_upload_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/ai_content_event.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/draft_status_event.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/repositories/lessor_repository.dart';

class LessorRepositoryImpl implements LessorRepository {
  final LessorRemoteDatasource _remote;

  LessorRepositoryImpl({required LessorRemoteDatasource remote})
    : _remote = remote;

  @override
  Future<List<NeighborhoodModel>> getNeighborhoods(String cp) =>
      _remote.getNeighborhoodsByPostalCode(cp);

  @override
  Future<List<AmenityModel>> getAmenities() => _remote.getAmenities();

  @override
  Future<void> checkCanPublish() => _remote.checkCanPublish();

  @override
  Future<DraftUploadModel> createDraft(Map<String, dynamic> body) =>
      _remote.createDraft(body);

  @override
  Future<void> uploadFile(
    String uploadUrl,
    String contentType,
    List<int> bytes,
  ) => _remote.uploadFile(uploadUrl, contentType, bytes);

  @override
  Stream<DraftStatusEvent> watchDraftStatus(String draftId) =>
      _remote.watchDraftStatus(draftId);

  @override
  Stream<AiContentEvent> generateAiContent(Map<String, dynamic> draft) =>
      _remote.generateAiContent(draft);
}

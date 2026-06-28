import 'package:vivia_mobile/features/lessor/data/datasources/remote/lessor_remote_datasource.dart';
import 'package:vivia_mobile/features/lessor/data/models/amenity_model.dart';
import 'package:vivia_mobile/features/lessor/data/models/draft_upload_model.dart';
import 'package:vivia_mobile/features/lessor/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/domain/repositories/lessor_repository.dart';

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
  Future<DraftUploadModel> createDraft(Map<String, dynamic> body) =>
      _remote.createDraft(body);

  @override
  Future<void> uploadFile(
          String uploadUrl, String contentType, List<int> bytes) =>
      _remote.uploadFile(uploadUrl, contentType, bytes);
}

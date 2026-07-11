import 'package:vivia_mobile/shared/property/data/datasources/remote/property_remote_datasource.dart';
import 'package:vivia_mobile/shared/property/data/models/media_upload_session_model.dart';
import 'package:vivia_mobile/shared/property/data/models/property_summary_model.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_detail.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_media.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_model.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_type_model.dart';
import 'package:vivia_mobile/shared/property/domain/repositories/property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDatasource _remote;

  PropertyRepositoryImpl({required PropertyRemoteDatasource remote})
      : _remote = remote;

  PropertyModel _toModel(PropertySummaryModel s, {bool isFavorite = false}) =>
      PropertyModel(
        id: s.id,
        title: s.title,
        type: s.propertyTypeName,
        price: s.listedPrice,
        location: '',
        area: s.areaM2,
        bedrooms: s.bedrooms,
        bathrooms: s.bathrooms,
        imageUrl: s.mainImageUrl,
        isFavorite: isFavorite,
      );

  @override
  Future<List<PropertyTypeModel>> getPropertyTypes() =>
      _remote.getPropertyTypes();

  @override
  Future<List<PropertyModel>> getPropertiesMe() async {
    final summaries = await _remote.getPropertiesMe();
    return summaries.map((s) => _toModel(s)).toList();
  }

  @override
  Future<List<PropertyModel>> getPropertiesMeLikes() async {
    final summaries = await _remote.getPropertiesMeLikes();
    return summaries.map((s) => _toModel(s, isFavorite: true)).toList();
  }

  @override
  Future<PropertyDetail> getPropertyById(String id) =>
      _remote.getPropertyById(id);

  @override
  Future<List<PropertyMedia>> getPropertyMedia(String id) =>
      _remote.getPropertyMedia(id);

  @override
  Future<List<PropertyModel>> getPropertySuggestions() async {
    final summaries = await _remote.getPropertySuggestions();
    return summaries.map((s) => _toModel(s)).toList();
  }

  @override
  Future<List<PropertyModel>> getPropertiesNearMe() async {
    final summaries = await _remote.getPropertiesNearMe();
    return summaries.map((s) => _toModel(s)).toList();
  }

  @override
  Future<bool> toggleLike(String propertyId) => _remote.toggleLike(propertyId);

  @override
  Future<void> deleteProperty(String id) => _remote.deleteProperty(id);

  @override
  Future<void> updateProperty(String id, Map<String, dynamic> body) =>
      _remote.updateProperty(id, body);

  @override
  Future<MediaUploadSessionModel> createMediaUploadSession(
    Map<String, dynamic> body,
  ) =>
      _remote.createMediaUploadSession(body);

  @override
  Future<void> changeMainImage(String mainImageId, String newMainImageId) =>
      _remote.changeMainImage(mainImageId, newMainImageId);

  @override
  Future<void> deleteMedia(String mediaId) => _remote.deleteMedia(mediaId);

  @override
  Future<void> uploadFile(
    String uploadUrl,
    String contentType,
    List<int> bytes,
  ) =>
      _remote.uploadFile(uploadUrl, contentType, bytes);
}

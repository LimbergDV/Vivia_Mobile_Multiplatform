import 'package:vivia_mobile/shared/property/data/models/media_upload_session_model.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_detail.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_media.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_model.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_type_model.dart';

abstract class PropertyRepository {
  Future<List<PropertyTypeModel>> getPropertyTypes();
  Future<List<PropertyModel>> getPropertiesMe();
  Future<List<PropertyModel>> getPropertiesMeLikes();
  Future<PropertyDetail> getPropertyById(String id);
  Future<List<PropertyMedia>> getPropertyMedia(String id);
  Future<List<PropertyModel>> getPropertySuggestions();
  Future<List<PropertyModel>> getPropertiesNearMe();
  Future<bool> toggleLike(String propertyId);
  Future<void> deleteProperty(String id);
  Future<MediaUploadSessionModel> createMediaUploadSession(
    Map<String, dynamic> body,
  );
  Future<void> changeMainImage(String mainImageId, String newMainImageId);
  Future<void> deleteMedia(String mediaId);
  Future<void> uploadFile(
    String uploadUrl,
    String contentType,
    List<int> bytes,
  );
}

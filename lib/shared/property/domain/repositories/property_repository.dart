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
}

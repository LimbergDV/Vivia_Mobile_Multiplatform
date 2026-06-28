import 'package:vivia_mobile/features/home/domain/models/property_model.dart';
import 'package:vivia_mobile/features/home/domain/models/property_type_model.dart';

abstract class PropertyRepository {
  Future<List<PropertyTypeModel>> getPropertyTypes();
  Future<List<PropertyModel>> getPropertiesMe();
  Future<List<PropertyModel>> getPropertiesMeLikes();
}

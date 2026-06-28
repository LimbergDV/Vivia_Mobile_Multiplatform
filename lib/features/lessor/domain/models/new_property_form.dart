import 'package:vivia_mobile/features/home/domain/models/property_type_model.dart';
import 'package:vivia_mobile/features/lessor/data/models/neighborhood_model.dart';

class NewPropertyForm {
  // Paso 1 - add_property_page
  final bool isAvailableToRent;
  final String? postalCode;
  final NeighborhoodModel? neighborhood;
  final PropertyTypeModel? propertyType;
  final String? street;
  final String? exteriorNumber;
  final String? interiorNumber;
  final String? price;
  final String? area;

  // Paso 2 - property_details_page
  final int? rooms;
  final int? bathrooms;
  final int? parkingSpots;
  final String? title;
  final String? description;
  final int? constructionYear;
  final bool isCondominium;
  final List<String> amenityIds;

  // Paso 3 - property_photos_page
  final String? mainPhotoPath;

  // Paso 4 - space_photos_page
  final Map<String, List<String>>? spacePhotos;

  // Paso 5 - tour_video_page
  final String? videoPath;

  const NewPropertyForm({
    this.isAvailableToRent = false,
    this.postalCode,
    this.neighborhood,
    this.propertyType,
    this.street,
    this.exteriorNumber,
    this.interiorNumber,
    this.price,
    this.area,
    this.rooms,
    this.bathrooms,
    this.parkingSpots,
    this.title,
    this.description,
    this.constructionYear,
    this.isCondominium = false,
    this.amenityIds = const [],
    this.mainPhotoPath,
    this.spacePhotos,
    this.videoPath,
  });

  NewPropertyForm copyWith({
    bool? isAvailableToRent,
    String? postalCode,
    NeighborhoodModel? neighborhood,
    PropertyTypeModel? propertyType,
    String? street,
    String? exteriorNumber,
    String? interiorNumber,
    String? price,
    String? area,
    int? rooms,
    int? bathrooms,
    int? parkingSpots,
    String? title,
    String? description,
    int? constructionYear,
    bool? isCondominium,
    List<String>? amenityIds,
    String? mainPhotoPath,
    Map<String, List<String>>? spacePhotos,
    String? videoPath,
  }) {
    return NewPropertyForm(
      isAvailableToRent: isAvailableToRent ?? this.isAvailableToRent,
      postalCode: postalCode ?? this.postalCode,
      neighborhood: neighborhood ?? this.neighborhood,
      propertyType: propertyType ?? this.propertyType,
      street: street ?? this.street,
      exteriorNumber: exteriorNumber ?? this.exteriorNumber,
      interiorNumber: interiorNumber ?? this.interiorNumber,
      price: price ?? this.price,
      area: area ?? this.area,
      rooms: rooms ?? this.rooms,
      bathrooms: bathrooms ?? this.bathrooms,
      parkingSpots: parkingSpots ?? this.parkingSpots,
      title: title ?? this.title,
      description: description ?? this.description,
      constructionYear: constructionYear ?? this.constructionYear,
      isCondominium: isCondominium ?? this.isCondominium,
      amenityIds: amenityIds ?? this.amenityIds,
      mainPhotoPath: mainPhotoPath ?? this.mainPhotoPath,
      spacePhotos: spacePhotos ?? this.spacePhotos,
      videoPath: videoPath ?? this.videoPath,
    );
  }
}

import 'package:vivia_mobile/shared/property/domain/models/property_detail.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_type_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/neighborhood_model.dart';

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

  /// Prellenado para el modo de edición de una propiedad publicada.
  /// Los medios no viajan por este flujo (se editan en la galería).
  factory NewPropertyForm.fromDetail(PropertyDetail detail) {
    final neighborhood = detail.address.neighborhood;
    return NewPropertyForm(
      isAvailableToRent: detail.availableToRent,
      postalCode: neighborhood.postalCode,
      neighborhood: NeighborhoodModel(
        id: neighborhood.id,
        name: neighborhood.name,
        postalCode: neighborhood.postalCode,
      ),
      propertyType: detail.propertyType,
      street: detail.address.street,
      exteriorNumber: detail.address.exteriorNumber,
      interiorNumber: detail.address.interiorNumber,
      price: detail.listedPrice.toStringAsFixed(0),
      area: detail.areaM2 % 1 == 0
          ? detail.areaM2.toStringAsFixed(0)
          : detail.areaM2.toString(),
      rooms: detail.bedrooms,
      // El detalle admite medios baños (double); el selector solo enteros.
      bathrooms: detail.bathrooms.round(),
      parkingSpots: detail.parkingSpaces,
      title: detail.title,
      description: detail.description,
      constructionYear: detail.constructionYear,
      isCondominium: detail.condominium,
      amenityIds: detail.amenities.map((a) => a.id).toList(),
    );
  }

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

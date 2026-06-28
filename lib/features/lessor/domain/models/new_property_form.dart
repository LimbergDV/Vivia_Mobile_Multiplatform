// lib/features/lessor/domain/models/new_property_form.dart

class NewPropertyForm {
  // Paso 1 - add_property_page
  final String? listingType;
  final String? postalCode;
  final String? city;
  final String? state;
  final String? colonia;
  final String? propertyType;
  final String? price;
  final String? area;

  // Paso 2 - property_details_page
  final int? rooms;
  final int? bathrooms;
  final int? parkingSpots;
  final String? title;
  final String? description;

  // Paso 3 - property_photos_page
  final String? mainPhotoPath;

  // Paso 4 - space_photos_page
  final Map<String, List<String>>? spacePhotos;

  // Paso 5 - tour_video_page
  final String? videoPath;

  const NewPropertyForm({
    this.listingType,
    this.postalCode,
    this.city,
    this.state,
    this.colonia,
    this.propertyType,
    this.price,
    this.area,
    this.rooms,
    this.bathrooms,
    this.parkingSpots,
    this.title,
    this.description,
    this.mainPhotoPath,
    this.spacePhotos,
    this.videoPath,
  });

  NewPropertyForm copyWith({
    String? listingType,
    String? postalCode,
    String? city,
    String? state,
    String? colonia,
    String? propertyType,
    String? price,
    String? area,
    int? rooms,
    int? bathrooms,
    int? parkingSpots,
    String? title,
    String? description,
    String? mainPhotoPath,
    Map<String, List<String>>? spacePhotos,
    String? videoPath,
  }) {
    return NewPropertyForm(
      listingType: listingType ?? this.listingType,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      state: state ?? this.state,
      colonia: colonia ?? this.colonia,
      propertyType: propertyType ?? this.propertyType,
      price: price ?? this.price,
      area: area ?? this.area,
      rooms: rooms ?? this.rooms,
      bathrooms: bathrooms ?? this.bathrooms,
      parkingSpots: parkingSpots ?? this.parkingSpots,
      title: title ?? this.title,
      description: description ?? this.description,
      mainPhotoPath: mainPhotoPath ?? this.mainPhotoPath,
      spacePhotos: spacePhotos ?? this.spacePhotos,
      videoPath: videoPath ?? this.videoPath,
    );
  }
}
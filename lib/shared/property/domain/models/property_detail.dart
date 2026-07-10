import 'package:vivia_mobile/shared/property/domain/models/property_media.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_type_model.dart';

/// Detalle completo de una propiedad (GET /properties/{id}).
/// Si el token es de un LESSEE, [lessor] y [like] vienen poblados;
/// para un LESSOR pueden ser null.
class PropertyDetail {
  final String id;
  final String title;
  final String description;
  final double areaM2;
  final int bedrooms;
  final double bathrooms;
  final int parkingSpaces;
  final int? constructionYear;
  final double listedPrice;
  final double pricePerM2;
  final PropertyTypeModel propertyType;
  final PropertyAddress address;
  final List<PropertyAmenity> amenities;
  final bool? like;
  final PropertyLessor? lessor;
  final bool availableToRent;
  final bool condominium;
  final List<PropertyMedia> media;

  /// Coordenadas persistidas al publicar; null en propiedades anteriores
  /// a que el draft las aceptara (ahí el mapa se resuelve geocodificando).
  final double? latitude;
  final double? longitude;

  const PropertyDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.areaM2,
    required this.bedrooms,
    required this.bathrooms,
    required this.parkingSpaces,
    required this.constructionYear,
    required this.listedPrice,
    required this.pricePerM2,
    required this.propertyType,
    required this.address,
    required this.amenities,
    required this.like,
    required this.lessor,
    required this.availableToRent,
    required this.condominium,
    required this.media,
    this.latitude,
    this.longitude,
  });

  /// URLs de los medios de tipo imagen.
  List<String> get imageUrls => media
      .where((m) => m.isImage)
      .map((m) => m.url)
      .where((url) => url.isNotEmpty)
      .toList();

  /// Construye el detalle desde el nodo `data` de la respuesta,
  /// que contiene `content` y `contentMedia`.
  factory PropertyDetail.fromResponse(Map<String, dynamic> data) {
    final content = data['content'] as Map<String, dynamic>;
    final mediaJson = data['contentMedia'] as List<dynamic>? ?? const [];
    final addressJson = content['address'] as Map<String, dynamic>;

    return PropertyDetail(
      id: content['id'] as String,
      title: content['title'] as String? ?? '',
      description: content['description'] as String? ?? '',
      areaM2: (content['areaM2'] as num?)?.toDouble() ?? 0,
      bedrooms: (content['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (content['bathrooms'] as num?)?.toDouble() ?? 0,
      parkingSpaces: (content['parkingSpaces'] as num?)?.toInt() ?? 0,
      constructionYear: (content['constructionYear'] as num?)?.toInt(),
      listedPrice: (content['listedPrice'] as num?)?.toDouble() ?? 0,
      pricePerM2: (content['pricePerM2'] as num?)?.toDouble() ?? 0,
      propertyType: PropertyTypeModel.fromJson(
        content['propertyType'] as Map<String, dynamic>,
      ),
      address: PropertyAddress.fromJson(addressJson),
      amenities: (content['amenities'] as List<dynamic>? ?? const [])
          .map((e) => PropertyAmenity.fromJson(e as Map<String, dynamic>))
          .toList(),
      like: content['like'] as bool?,
      lessor: content['lessor'] == null
          ? null
          : PropertyLessor.fromJson(content['lessor'] as Map<String, dynamic>),
      availableToRent: content['availableToRent'] as bool? ?? false,
      condominium: content['condominium'] as bool? ?? false,
      media: mediaJson
          .map((e) => PropertyMedia.fromJson(e as Map<String, dynamic>))
          .toList(),
      // El backend las expone dentro de content.address.
      latitude: (addressJson['latitude'] as num?)?.toDouble(),
      longitude: (addressJson['longitude'] as num?)?.toDouble(),
    );
  }
}

class PropertyAddress {
  final String id;
  final String street;
  final String exteriorNumber;
  final String? interiorNumber;
  final PropertyNeighborhood neighborhood;

  const PropertyAddress({
    required this.id,
    required this.street,
    required this.exteriorNumber,
    required this.interiorNumber,
    required this.neighborhood,
  });

  /// Dirección legible para mostrar en la UI.
  String get formatted {
    final interior =
        (interiorNumber != null && interiorNumber!.isNotEmpty)
            ? ' Int. $interiorNumber'
            : '';
    return '$street $exteriorNumber$interior, '
        '${neighborhood.name}, CP ${neighborhood.postalCode}';
  }

  factory PropertyAddress.fromJson(Map<String, dynamic> json) => PropertyAddress(
        id: json['id'] as String? ?? '',
        street: json['street'] as String? ?? '',
        exteriorNumber: json['exteriorNumber'] as String? ?? '',
        interiorNumber: json['interiorNumber'] as String?,
        neighborhood: PropertyNeighborhood.fromJson(
          json['neighborhood'] as Map<String, dynamic>,
        ),
      );
}

class PropertyNeighborhood {
  final String id;
  final String name;
  final String postalCode;

  const PropertyNeighborhood({
    required this.id,
    required this.name,
    required this.postalCode,
  });

  factory PropertyNeighborhood.fromJson(Map<String, dynamic> json) =>
      PropertyNeighborhood(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        postalCode: json['postalCode'] as String? ?? '',
      );
}

class PropertyAmenity {
  final String id;
  final String name;

  const PropertyAmenity({required this.id, required this.name});

  factory PropertyAmenity.fromJson(Map<String, dynamic> json) => PropertyAmenity(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );
}

class PropertyLessor {
  final String id;
  final String name;
  final String paternalSurname;
  final String maternalSurname;
  final String? photoUrl;

  const PropertyLessor({
    required this.id,
    required this.name,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.photoUrl,
  });

  String get fullName =>
      [name, paternalSurname, maternalSurname]
          .where((s) => s.isNotEmpty)
          .join(' ');

  factory PropertyLessor.fromJson(Map<String, dynamic> json) => PropertyLessor(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        paternalSurname: json['paternalSurname'] as String? ?? '',
        maternalSurname: json['maternalSurname'] as String? ?? '',
        photoUrl: json['photoUrl'] as String?,
      );
}


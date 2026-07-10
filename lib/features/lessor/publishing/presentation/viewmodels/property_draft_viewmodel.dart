import 'dart:async';
import 'package:vivia_mobile/core/utils/media_file_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vivia_mobile/features/maps/domain/models/geocode_result.dart';
import 'package:vivia_mobile/features/maps/domain/usecases/geocode_address_usecase.dart';
import 'package:vivia_mobile/features/maps/domain/usecases/reverse_geocode_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_type_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/amenity_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/draft_upload_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/draft_status_event.dart';
import 'package:vivia_mobile/shared/property/domain/models/media_manifest_item.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/new_property_form.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/get_amenities_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/get_neighborhoods_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/publish_property_draft_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/watch_draft_status_usecase.dart';

enum NeighborhoodsStatus { idle, loading, success, error }

/// [needsPin]: el geocoding solo resolvió a nivel colonia/CP (o 404) y el
/// usuario debe colocar el pin manualmente en el mapa de la revisión.
enum LocationPreviewStatus { idle, loading, ready, needsPin, unavailable }

enum AmenitiesStatus { idle, loading, success, error }

enum PublishStatus { idle, loading, success, error }

enum DraftStreamStatus { idle, validating, success, failed }

class PropertyDraftViewModel extends ChangeNotifier {
  final GetNeighborhoodsUseCase _getNeighborhoods;
  final GetAmenitiesUseCase _getAmenities;
  final PublishPropertyDraftUseCase _publishDraft;
  final WatchDraftStatusUseCase _watchDraftStatus;
  final GeocodeAddressUseCase? _geocodeAddress;
  final ReverseGeocodeUseCase? _reverseGeocode;

  PropertyDraftViewModel({
    required GetNeighborhoodsUseCase getNeighborhoodsUseCase,
    required GetAmenitiesUseCase getAmenitiesUseCase,
    required PublishPropertyDraftUseCase publishPropertyDraftUseCase,
    required WatchDraftStatusUseCase watchDraftStatusUseCase,
    GeocodeAddressUseCase? geocodeAddressUseCase,
    ReverseGeocodeUseCase? reverseGeocodeUseCase,
  }) : _getNeighborhoods = getNeighborhoodsUseCase,
       _getAmenities = getAmenitiesUseCase,
       _publishDraft = publishPropertyDraftUseCase,
       _watchDraftStatus = watchDraftStatusUseCase,
       _geocodeAddress = geocodeAddressUseCase,
       _reverseGeocode = reverseGeocodeUseCase;

  // ── Estado del formulario ─────────────────────────────────────────────────
  NewPropertyForm _form = const NewPropertyForm();
  List<NeighborhoodModel> _neighborhoods = [];
  List<AmenityModel> _amenities = [];
  NeighborhoodsStatus _neighborhoodsStatus = NeighborhoodsStatus.idle;
  AmenitiesStatus _amenitiesStatus = AmenitiesStatus.idle;
  PublishStatus _publishStatus = PublishStatus.idle;
  String? _publishError;
  String? _publishedDraftId;

  // ── Vista previa de ubicación en el mapa (solo visual) ───────────────────
  Timer? _previewDebounce;
  int _previewGeneration = 0;
  LocationPreviewStatus _previewStatus = LocationPreviewStatus.idle;
  GeocodeResult? _previewPoint;

  // Pin colocado manualmente por el usuario cuando el geocoding no resolvió
  // el predio exacto. Tiene prioridad sobre _previewPoint al publicar.
  GeocodeResult? _manualPoint;
  String? _manualAddressLabel;

  LocationPreviewStatus get previewStatus => _previewStatus;
  GeocodeResult? get previewPoint => _previewPoint;
  GeocodeResult? get manualPoint => _manualPoint;
  String? get manualAddressLabel => _manualAddressLabel;

  // Centro del mapa para colocar el pin: el pin manual si ya existe, luego
  // el punto aproximado del geocoding, y como último recurso Tuxtla (sin
  // catálogo de municipios aún no hay mejor ancla tras un 404).
  static const _tuxtlaCenter = GeocodeResult(
    lat: 16.7452,
    lon: -93.1418,
    displayName: 'Tuxtla Gutiérrez',
    precision: GeocodePrecision.postcode,
  );
  GeocodeResult get pinMapCenter =>
      _manualPoint ?? _previewPoint ?? _tuxtlaCenter;

  // ── Estado del stream de validación ──────────────────────────────────────
  StreamSubscription<DraftStatusEvent>? _streamSubscription;
  DraftStreamStatus _streamStatus = DraftStreamStatus.idle;
  String _streamStatusLabel = '';
  DraftPublicationSuccess? _successData;
  DraftPublicationFailed? _failureData;

  // ── Getters del formulario ────────────────────────────────────────────────
  NewPropertyForm get form => _form;
  List<NeighborhoodModel> get neighborhoods => _neighborhoods;
  List<AmenityModel> get amenities => _amenities;
  NeighborhoodsStatus get neighborhoodsStatus => _neighborhoodsStatus;
  AmenitiesStatus get amenitiesStatus => _amenitiesStatus;
  PublishStatus get publishStatus => _publishStatus;
  String? get publishError => _publishError;
  String? get publishedDraftId => _publishedDraftId;

  // ── Getters del stream ────────────────────────────────────────────────────
  DraftStreamStatus get streamStatus => _streamStatus;
  String get streamStatusLabel => _streamStatusLabel;
  DraftPublicationSuccess? get successData => _successData;
  DraftPublicationFailed? get failureData => _failureData;

  // ── Inicialización ────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_amenitiesStatus != AmenitiesStatus.idle) return;
    _amenitiesStatus = AmenitiesStatus.loading;
    notifyListeners();
    try {
      _amenities = await _getAmenities.execute();
      _amenitiesStatus = AmenitiesStatus.success;
    } catch (_) {
      _amenitiesStatus = AmenitiesStatus.error;
    } finally {
      notifyListeners();
    }
  }

  // No toca _publishStatus/_publishError: esos reflejan la publicación en
  // curso en segundo plano, que puede seguir viva después de iniciar un
  // borrador nuevo.
  void reset() {
    _form = const NewPropertyForm();
    _neighborhoods = [];
    _neighborhoodsStatus = NeighborhoodsStatus.idle;
    _publishStatus = PublishStatus.idle;
    _publishError = null;
    _publishedDraftId = null;
    _previewDebounce?.cancel();
    _previewGeneration++;
    _previewStatus = LocationPreviewStatus.idle;
    _previewPoint = null;
    _manualPoint = null;
    _manualAddressLabel = null;
    notifyListeners();
  }

  // ── Stream de validación en background ───────────────────────────────────
  void startValidationStream(String draftId) {
    _streamStatus = DraftStreamStatus.validating;
    _streamStatusLabel = '';
    _successData = null;
    _failureData = null;
    _streamSubscription?.cancel();
    _streamSubscription = _watchDraftStatus.execute(draftId).listen((event) {
      switch (event) {
        case DraftStatusUpdate(:final status):
          _streamStatusLabel = status;
        case DraftPublicationSuccess():
          _streamStatus = DraftStreamStatus.success;
          _successData = event;
          _streamSubscription = null;
        case DraftPublicationFailed():
          _streamStatus = DraftStreamStatus.failed;
          _failureData = event;
          _streamSubscription = null;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void clearStreamStatus() {
    _streamStatus = DraftStreamStatus.idle;
    _successData = null;
    _failureData = null;
    _streamStatusLabel = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _previewDebounce?.cancel();
    super.dispose();
  }

  // ── Campos del formulario Paso 1 ──────────────────────────────────────────
  void setListingType(bool isAvailableToRent) {
    _form = _form.copyWith(isAvailableToRent: isAvailableToRent);
    notifyListeners();
  }

  void setPostalCode(String cp) {
    _form = _form.copyWith(postalCode: cp);
    // Limpiar colonia seleccionada cuando cambia el CP
    _form = _form.copyWith(neighborhood: null);
    _neighborhoods = [];
    _neighborhoodsStatus = NeighborhoodsStatus.idle;
    notifyListeners();
    _scheduleLocationPreview();
    if (cp.length == 5) fetchNeighborhoods(cp);
  }

  void setNeighborhood(NeighborhoodModel neighborhood) {
    _form = _form.copyWith(neighborhood: neighborhood);
    notifyListeners();
    _scheduleLocationPreview();
  }

  void setPropertyType(PropertyTypeModel propertyType) {
    _form = _form.copyWith(propertyType: propertyType);
    notifyListeners();
  }

  void setStreet(String street) {
    _form = _form.copyWith(street: street);
    notifyListeners();
    _scheduleLocationPreview();
  }

  /// Geocodifica la dirección capturada con el endpoint estructurado
  /// (/geocode/address): manda cp + calle + numero + colonia — cada campo
  /// extra sube la precisión. Debounce agresivo: el servicio no está pensado
  /// para search-as-you-type (integration.md §4.7). El punto resuelto (o el
  /// pin manual) viaja como latitude/longitude en el draft (_buildFormBody).
  void _scheduleLocationPreview() {
    final geocode = _geocodeAddress;
    if (geocode == null) return;

    _previewDebounce?.cancel();
    final street = _form.street?.trim() ?? '';
    final neighborhood = _form.neighborhood;
    final cp = (neighborhood?.postalCode ?? _form.postalCode ?? '').trim();
    if (street.length < 5 || neighborhood == null || cp.length != 5) {
      if (_previewStatus != LocationPreviewStatus.idle) {
        _previewStatus = LocationPreviewStatus.idle;
        _previewPoint = null;
        _manualPoint = null;
        _manualAddressLabel = null;
        notifyListeners();
      }
      return;
    }

    _previewDebounce = Timer(const Duration(milliseconds: 900), () async {
      final generation = ++_previewGeneration;
      _previewStatus = LocationPreviewStatus.loading;
      notifyListeners();
      try {
        final result = await geocode.execute(
          cp: cp,
          street: street,
          exteriorNumber: _form.exteriorNumber,
          neighborhood: neighborhood.name,
        );
        if (generation != _previewGeneration) return; // respuesta obsoleta
        _previewPoint = result;
        // null = 404 (fuera de zona de servicio según OSM) y aproximado =
        // colonia/CP: en ambos casos el usuario coloca el pin manualmente.
        _previewStatus = (result == null || result.isApproximate)
            ? LocationPreviewStatus.needsPin
            : LocationPreviewStatus.ready;
      } catch (_) {
        if (generation != _previewGeneration) return;
        _previewPoint = null;
        _previewStatus = LocationPreviewStatus.unavailable;
      }
      // La dirección cambió: un pin manual anterior ya no aplica.
      _manualPoint = null;
      _manualAddressLabel = null;
      notifyListeners();
    });
  }

  /// Pin colocado por el usuario en el mapa. Confirma la dirección con
  /// /reverse; las coordenadas son válidas aunque el reverse no resuelva.
  Future<void> setManualPoint(double lat, double lon) async {
    _manualPoint = GeocodeResult(
      lat: lat,
      lon: lon,
      displayName: '',
      precision: GeocodePrecision.exact,
    );
    _manualAddressLabel = null;
    notifyListeners();

    final reverse = _reverseGeocode;
    if (reverse == null) return;
    try {
      final name = await reverse.execute(lat, lon);
      // Ignorar si el usuario ya movió el pin a otro lado.
      if (_manualPoint?.lat != lat || _manualPoint?.lon != lon) return;
      _manualAddressLabel = name ??
          'Ubicación sin dirección registrada '
              '(${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)})';
    } catch (_) {
      // Reverse falló: el pin sigue siendo válido, solo sin etiqueta.
    }
    notifyListeners();
  }

  void setExteriorNumber(String number) {
    _form = _form.copyWith(exteriorNumber: number);
    notifyListeners();
    // El número exterior habilita la precisión "exact" del geocoding.
    _scheduleLocationPreview();
  }

  void setInteriorNumber(String number) {
    _form = _form.copyWith(interiorNumber: number);
    notifyListeners();
  }

  void setPrice(String price) {
    _form = _form.copyWith(price: price);
    notifyListeners();
  }

  void setArea(String area) {
    _form = _form.copyWith(area: area);
    notifyListeners();
  }

  // ── Campos del formulario Paso 2 ──────────────────────────────────────────
  void setRooms(int rooms) {
    _form = _form.copyWith(rooms: rooms);
    notifyListeners();
  }

  void setBathrooms(int bathrooms) {
    _form = _form.copyWith(bathrooms: bathrooms);
    notifyListeners();
  }

  void setParkingSpots(int spots) {
    _form = _form.copyWith(parkingSpots: spots);
    notifyListeners();
  }

  void setTitle(String title) {
    _form = _form.copyWith(title: title);
    notifyListeners();
  }

  void setDescription(String description) {
    _form = _form.copyWith(description: description);
    notifyListeners();
  }

  void setConstructionYear(int? year) {
    _form = _form.copyWith(constructionYear: year);
    notifyListeners();
  }

  void setIsCondominium(bool value) {
    _form = _form.copyWith(isCondominium: value);
    notifyListeners();
  }

  void toggleAmenity(String id) {
    final current = List<String>.from(_form.amenityIds);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    _form = _form.copyWith(amenityIds: current);
    notifyListeners();
  }

  // ── Campos multimedia ─────────────────────────────────────────────────────
  void setMainPhotoPath(String path) {
    _form = _form.copyWith(mainPhotoPath: path);
    notifyListeners();
  }

  void setSpacePhotos(Map<String, List<String>> photos) {
    _form = _form.copyWith(spacePhotos: photos);
    notifyListeners();
  }

  void setVideoPath(String? path) {
    _form = _form.copyWith(videoPath: path);
    notifyListeners();
  }

  // ── Colonias dinámicas ────────────────────────────────────────────────────
  Future<void> fetchNeighborhoods(String cp) async {
    _neighborhoodsStatus = NeighborhoodsStatus.loading;
    notifyListeners();
    try {
      _neighborhoods = await _getNeighborhoods.execute(cp);
      _neighborhoodsStatus = NeighborhoodsStatus.success;
    } catch (_) {
      _neighborhoods = [];
      _neighborhoodsStatus = NeighborhoodsStatus.error;
    } finally {
      notifyListeners();
    }
  }

  // ── Publicación: dos fases ────────────────────────────────────────────────
  //
  // Fase A (awaitable): construye el manifiesto y hace POST /properties/draft.
  // Al retornar, publishStatus es success o error — la UI navega a home en success.
  // Fase B (background): sube la media a S3 y arranca el SSE.
  Future<void> publish({
    required String mainPhotoPath,
    required Map<String, List<String>> spacePhotos,
    String? videoPath,
  }) async {
    if (_publishStatus == PublishStatus.loading) return;

    _publishStatus = PublishStatus.loading;
    _publishError = null;
    notifyListeners();

    try {
      final formBody = _buildFormBody();
      final manifest = <MediaManifestItem>[];
      final fileKeyToPath = <String, String>{};

      // Foto principal → classification MAIN
      final mainKey = MediaFileUtils.fileKey(mainPhotoPath);
      manifest.add(
        MediaManifestItem(
          fileKey: mainKey,
          contentType: MediaFileUtils.contentType(mainPhotoPath),
          sizeBytes: await XFile(mainPhotoPath).length(),
          classification: 'MAIN',
        ),
      );
      fileKeyToPath[mainKey] = mainPhotoPath;

      // Fotos de espacios → classification = nombre de categoría en MAYÚSCULAS
      for (final entry in spacePhotos.entries) {
        final classification = entry.key.toUpperCase();
        for (final path in entry.value) {
          final key = MediaFileUtils.uniqueFileKey(path, fileKeyToPath);
          manifest.add(
            MediaManifestItem(
              fileKey: key,
              contentType: MediaFileUtils.contentType(path),
              sizeBytes: await XFile(path).length(),
              classification: classification,
            ),
          );
          fileKeyToPath[key] = path;
        }
      }

      // Video → classification TOUR
      if (videoPath != null) {
        final videoKey = MediaFileUtils.uniqueFileKey(videoPath, fileKeyToPath);
        manifest.add(
          MediaManifestItem(
            fileKey: videoKey,
            contentType: 'video/mp4',
            sizeBytes: await XFile(videoPath).length(),
            classification: 'TOUR',
          ),
        );
        fileKeyToPath[videoKey] = videoPath;
      }

      // Fase A: POST → obtiene draftId + URLs de S3. La UI espera esto.
      final draftUpload = await _publishDraft.createDraft(
        formBody: formBody,
        manifest: manifest,
      );

      _publishStatus = PublishStatus.success;
      _publishedDraftId = draftUpload.draftId;
      notifyListeners(); // la UI navega al home aquí

      // Fase B: sube media y arranca SSE en background (no bloqueante).
      _uploadAndStream(draftUpload.draftId, draftUpload.uploads, fileKeyToPath);
    } catch (e) {
      _publishStatus = PublishStatus.error;
      _publishError = e.toString();
      notifyListeners();
    }
  }

  Future<void> _uploadAndStream(
    String draftId,
    List<DraftUploadItem> uploads,
    Map<String, String> fileKeyToPath,
  ) async {
    try {
      await _publishDraft.uploadMedia(
        uploads: uploads,
        fileKeyToPath: fileKeyToPath,
      );
      startValidationStream(draftId);
    } catch (e) {
      _publishStatus = PublishStatus.error;
      _publishError = e.toString();
    } finally {
      _form = const NewPropertyForm();
      _neighborhoods = [];
      _neighborhoodsStatus = NeighborhoodsStatus.idle;
      _publishedDraftId = null;
      if (_publishStatus != PublishStatus.error)
        _publishStatus = PublishStatus.idle;
      notifyListeners();
    }
  }

  Map<String, dynamic> _buildFormBody() {
    return {
      'propertyTypeId': _form.propertyType!.id,
      'neighborhoodId': _form.neighborhood!.id,
      'street': _form.street ?? '',
      'exteriorNumber': _form.exteriorNumber ?? '',
      if (_form.interiorNumber != null && _form.interiorNumber!.isNotEmpty)
        'interiorNumber': _form.interiorNumber,
      'isAvailableToRent': _form.isAvailableToRent,
      'title': _form.title ?? '',
      'description': _form.description ?? '',
      'areaM2': double.tryParse(_form.area ?? '0') ?? 0.0,
      'bedrooms': _form.rooms ?? 0,
      'bathrooms': (_form.bathrooms ?? 0).toDouble(),
      'parkingSpaces': _form.parkingSpots ?? 0,
      if (_form.constructionYear != null)
        'constructionYear': _form.constructionYear,
      'isCondominium': _form.isCondominium,
      'listedPrice': double.tryParse(_form.price ?? '0') ?? 0.0,
      'amenityIds': _form.amenityIds,
      // Guardar siempre las coordenadas resultantes: el pin manual tiene
      // prioridad; si no hay, el geocoding solo cuando resolvió el predio
      // (ready). Sin punto, el draft va sin coordenadas (opcionales).
      if (_publishPoint != null) ...{
        'latitude': _publishPoint!.lat,
        'longitude': _publishPoint!.lon,
      },
    };
  }

  GeocodeResult? get _publishPoint =>
      _manualPoint ??
      (_previewStatus == LocationPreviewStatus.ready ? _previewPoint : null);
}

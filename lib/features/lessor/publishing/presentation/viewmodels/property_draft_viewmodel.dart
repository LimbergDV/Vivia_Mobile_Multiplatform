import 'dart:async';
import 'package:vivia_mobile/core/utils/input_sanitizer.dart';
import 'package:vivia_mobile/core/utils/media_file_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vivia_mobile/features/maps/domain/models/geocode_result.dart';
import 'package:vivia_mobile/features/maps/domain/usecases/geocode_address_usecase.dart';
import 'package:vivia_mobile/features/maps/domain/usecases/reverse_geocode_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_type_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/amenity_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/draft_upload_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/models/neighborhood_model.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/ai_content_event.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/draft_status_event.dart';
import 'package:vivia_mobile/shared/property/domain/models/media_manifest_item.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/models/new_property_form.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/generate_ai_content_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/get_amenities_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/get_neighborhoods_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/publish_property_draft_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/watch_draft_status_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_detail.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/update_property_usecase.dart';

enum NeighborhoodsStatus { idle, loading, success, error }

enum AiGenerationStatus { idle, loading, error, premiumRequired, subscriptionCheckFailed }

/// [needsPin]: el geocoding solo resolvió a nivel colonia/CP (o 404) y el
/// usuario debe colocar el pin manualmente en el mapa de la revisión.
enum LocationPreviewStatus { idle, loading, ready, needsPin, unavailable }

enum AmenitiesStatus { idle, loading, success, error }

enum PublishStatus { idle, loading, success, error }

enum DraftStreamStatus { idle, validating, success, failed }

/// Modo de uso del formulario de propiedad:
/// - [create]: flujo completo de publicación (incluye fotos y "Publicar").
/// - [editPreview]: edición del draft desde la vista previa; salta las
///   páginas de fotos y regresa a la review.
/// - [editPublished]: edición de una propiedad ya publicada; salta las
///   páginas de fotos y guarda con PATCH /properties/{id}.
enum PropertyFormMode { create, editPreview, editPublished }

class PropertyDraftViewModel extends ChangeNotifier {
  final GetNeighborhoodsUseCase _getNeighborhoods;
  final GetAmenitiesUseCase _getAmenities;
  final PublishPropertyDraftUseCase _publishDraft;
  final WatchDraftStatusUseCase _watchDraftStatus;
  final GeocodeAddressUseCase? _geocodeAddress;
  final ReverseGeocodeUseCase? _reverseGeocode;
  final UpdatePropertyUseCase? _updateProperty;
  final GenerateAiContentUseCase? _generateAiContent;

  PropertyDraftViewModel({
    required GetNeighborhoodsUseCase getNeighborhoodsUseCase,
    required GetAmenitiesUseCase getAmenitiesUseCase,
    required PublishPropertyDraftUseCase publishPropertyDraftUseCase,
    required WatchDraftStatusUseCase watchDraftStatusUseCase,
    GeocodeAddressUseCase? geocodeAddressUseCase,
    ReverseGeocodeUseCase? reverseGeocodeUseCase,
    UpdatePropertyUseCase? updatePropertyUseCase,
    GenerateAiContentUseCase? generateAiContentUseCase,
  }) : _getNeighborhoods = getNeighborhoodsUseCase,
       _getAmenities = getAmenitiesUseCase,
       _publishDraft = publishPropertyDraftUseCase,
       _watchDraftStatus = watchDraftStatusUseCase,
       _geocodeAddress = geocodeAddressUseCase,
       _reverseGeocode = reverseGeocodeUseCase,
       _updateProperty = updatePropertyUseCase,
       _generateAiContent = generateAiContentUseCase;

  // ── Estado del formulario ─────────────────────────────────────────────────
  NewPropertyForm _form = const NewPropertyForm();
  List<NeighborhoodModel> _neighborhoods = [];
  List<AmenityModel> _amenities = [];
  NeighborhoodsStatus _neighborhoodsStatus = NeighborhoodsStatus.idle;
  AmenitiesStatus _amenitiesStatus = AmenitiesStatus.idle;
  PublishStatus _publishStatus = PublishStatus.idle;
  String? _publishError;
  String? _publishedDraftId;

  // ── Modo del formulario y guardado de ediciones ───────────────────────────
  PropertyFormMode _mode = PropertyFormMode.create;
  String? _editingPropertyId;
  PublishStatus _saveStatus = PublishStatus.idle;
  String? _saveError;

  PropertyFormMode get mode => _mode;
  String? get editingPropertyId => _editingPropertyId;
  PublishStatus get saveStatus => _saveStatus;
  String? get saveError => _saveError;

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

  // ── Estado de generación IA ───────────────────────────────────────────────
  AiGenerationStatus _aiStatus = AiGenerationStatus.idle;
  String? _aiError;
  String _aiStreamTitle = '';
  String _aiStreamDescription = '';
  StreamSubscription<AiContentEvent>? _aiSubscription;

  // Último título y descripción generados: safety net si los campos quedaron vacíos.
  String? _aiLastTitle;
  String? _aiLastDescription;

  // Rate limiting: máximo 3 llamadas por ventana de 5 minutos.
  final List<DateTime> _aiCallTimestamps = [];

  // Throttle: un solo rebuild por frame durante el stream de deltas.
  bool _notifyPending = false;
  void _throttledNotify() {
    if (_notifyPending) return;
    _notifyPending = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notifyPending = false;
      if (hasListeners) notifyListeners();
    });
  }

  AiGenerationStatus get aiStatus => _aiStatus;
  String? get aiError => _aiError;
  String get aiStreamTitle => _aiStreamTitle;
  String get aiStreamDescription => _aiStreamDescription;
  String? get aiLastTitle => _aiLastTitle;
  String? get aiLastDescription => _aiLastDescription;

  bool get isAiRateLimited {
    _aiCallTimestamps.removeWhere(
      (t) => DateTime.now().difference(t) > const Duration(minutes: 5),
    );
    return _aiCallTimestamps.length >= 3;
  }

  bool get canGenerateAiContent =>
      _form.propertyType != null &&
      _form.neighborhood != null &&
      (_form.area?.isNotEmpty ?? false) &&
      (_form.price?.isNotEmpty ?? false) &&
      _form.rooms != null &&
      _form.bathrooms != null;

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

  String get streamStatusMessage {
    final s = _streamStatusLabel.toUpperCase();
    if (s.contains('UPLOAD') || s.contains('MEDIA') || s.contains('IMAGE')) {
      return 'Procesando las imágenes…';
    }
    if (s.contains('MODERA') || s.contains('REVIEW')) {
      return 'Revisando el contenido…';
    }
    if (s.contains('VALID')) return 'Validando la información…';
    if (s.contains('PUBLISH')) return 'Publicando tu propiedad…';
    return 'Procesando tu publicación…';
  }

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
    _mode = PropertyFormMode.create;
    _editingPropertyId = null;
    _saveStatus = PublishStatus.idle;
    _saveError = null;
    _previewDebounce?.cancel();
    _previewGeneration++;
    _previewStatus = LocationPreviewStatus.idle;
    _previewPoint = null;
    _manualPoint = null;
    _manualAddressLabel = null;
    _aiSubscription?.cancel();
    _aiSubscription = null;
    _aiStatus = AiGenerationStatus.idle;
    _aiError = null;
    _aiStreamTitle = '';
    _aiStreamDescription = '';
    _aiLastTitle = null;
    _aiLastDescription = null;
    notifyListeners();
  }

  // ── Modos de edición ──────────────────────────────────────────────────────

  /// Entra al modo de edición desde la vista previa: el draft ya contiene
  /// los datos, solo se marca el modo para que las páginas salten las fotos.
  void startPreviewEdit() {
    _mode = PropertyFormMode.editPreview;
    notifyListeners();
  }

  /// Entra al modo de edición de una propiedad publicada: prellena el
  /// formulario desde [detail] y deja fuera los medios (tienen flujo propio).
  Future<void> startPublishedEdit(PropertyDetail detail) async {
    _mode = PropertyFormMode.editPublished;
    _editingPropertyId = detail.id;
    _saveStatus = PublishStatus.idle;
    _saveError = null;
    _form = NewPropertyForm.fromDetail(detail);

    // Geocoding limpio: si el usuario no toca la dirección no se envían
    // coordenadas y el backend conserva las actuales.
    _previewDebounce?.cancel();
    _previewGeneration++;
    _previewStatus = LocationPreviewStatus.idle;
    _previewPoint = null;
    _manualPoint = null;
    _manualAddressLabel = null;

    // Sembrar la colonia actual para que el dropdown tenga valor mientras
    // se cargan todas las opciones del CP.
    final seeded = _form.neighborhood;
    _neighborhoods = seeded != null ? [seeded] : [];
    _neighborhoodsStatus = NeighborhoodsStatus.success;
    notifyListeners();

    final cp = _form.postalCode ?? '';
    if (cp.length == 5) {
      await fetchNeighborhoods(cp);
      if (_neighborhoods.isEmpty && seeded != null) {
        // La carga falló: conservar al menos la colonia actual.
        _neighborhoods = [seeded];
        _neighborhoodsStatus = NeighborhoodsStatus.success;
        notifyListeners();
      }
    }
  }

  /// Guarda los cambios de una propiedad publicada con PATCH /properties/{id}.
  /// Devuelve true en éxito para que la página navegue de regreso.
  Future<bool> saveEdits() async {
    final update = _updateProperty;
    final id = _editingPropertyId;
    if (update == null || id == null) return false;
    if (_saveStatus == PublishStatus.loading) return false;

    _saveStatus = PublishStatus.loading;
    _saveError = null;
    notifyListeners();
    try {
      await update.execute(id, _buildPatchBody());
      _saveStatus = PublishStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _saveStatus = PublishStatus.error;
      _saveError = e.toString();
      notifyListeners();
      return false;
    }
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

  // ── Generación IA ─────────────────────────────────────────────────────────

  Future<void> generateAiContent() async {
    if (_aiStatus == AiGenerationStatus.loading) return;
    final gen = _generateAiContent;
    if (gen == null) return;

    if (isAiRateLimited) {
      _aiStatus = AiGenerationStatus.error;
      _aiError = 'Límite alcanzado: máximo 3 generaciones por 5 minutos.';
      notifyListeners();
      return;
    }
    _aiCallTimestamps.add(DateTime.now());

    _aiSubscription?.cancel();
    _aiStatus = AiGenerationStatus.loading;
    _aiError = null;
    _aiStreamTitle = '';
    _aiStreamDescription = '';
    notifyListeners();

    try {
      final draft = _buildAiDraft();
      _aiSubscription = gen
          .execute(draft)
          .timeout(
            const Duration(seconds: 120),
            onTimeout: (sink) => sink.addError(
              Exception('La generación tardó demasiado. Intenta de nuevo.'),
            ),
          )
          .listen(
        (event) {
          switch (event) {
            // Eventos frecuentes: throttle a un rebuild por frame.
            case AiContentQueued():
              _throttledNotify();
            case AiContentDelta(:final text):
              _aiStreamDescription += text;
              _throttledNotify();
            // Eventos únicos: notify inmediato para respuesta rápida.
            case AiContentTitle(:final text):
              _aiStreamTitle = text;
              notifyListeners();
            case AiContentDone(:final title, :final description):
              _aiStatus = AiGenerationStatus.idle;
              _aiSubscription = null;
              _aiLastTitle = title;
              _aiLastDescription = description;
              // Atomic update: both fields set before the single notify,
              // so _onVmChanged sees the complete state in one pass.
              _form = _form.copyWith(title: title, description: description);
              notifyListeners();
            case AiContentError(:final detail):
              _aiStatus = AiGenerationStatus.error;
              _aiError = detail;
              _aiSubscription = null;
              notifyListeners();
            case AiContentPremiumRequired():
              _aiStatus = AiGenerationStatus.premiumRequired;
              _aiSubscription = null;
              notifyListeners();
            case AiContentSubscriptionCheckFailed():
              _aiStatus = AiGenerationStatus.subscriptionCheckFailed;
              _aiError =
                  'No se pudo verificar tu suscripción. Intenta de nuevo.';
              _aiSubscription = null;
              notifyListeners();
          }
        },
        onError: (Object e) {
          _aiStatus = AiGenerationStatus.error;
          _aiError = e.toString().replaceFirst('Exception: ', '');
          _aiSubscription = null;
          notifyListeners();
        },
        onDone: () {
          if (_aiStatus == AiGenerationStatus.loading) {
            _aiStatus = AiGenerationStatus.error;
            _aiError = 'La generación terminó inesperadamente.';
            notifyListeners();
          }
        },
      );
    } catch (e) {
      _aiStatus = AiGenerationStatus.error;
      _aiError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void cancelAiGeneration() {
    _aiSubscription?.cancel();
    _aiSubscription = null;
    if (_aiStatus == AiGenerationStatus.loading) {
      _aiStatus = AiGenerationStatus.idle;
      _aiStreamTitle = '';
      _aiStreamDescription = '';
      notifyListeners();
    }
  }

  Map<String, dynamic> _buildAiDraft() {
    final amenityNames = _form.amenityIds
        .map((id) => _amenities
            .firstWhere(
              (a) => a.id == id,
              orElse: () => AmenityModel(id: id, name: id),
            )
            .name)
        .toList();

    return {
      'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
      'propertyType': {
        'id': _form.propertyType!.id,
        'name': _form.propertyType!.name,
      },
      'address': {'neighborhoodName': _form.neighborhood!.name},
      'availableToRent': _form.isAvailableToRent,
      'areaM2': double.tryParse(_form.area ?? '0') ?? 0.0,
      'bedrooms': _form.rooms ?? 0,
      'bathrooms': (_form.bathrooms ?? 0).toDouble(),
      'parkingSpaces': _form.parkingSpots ?? 0,
      if (_form.constructionYear != null)
        'constructionYear': _form.constructionYear!,
      'condominium': _form.isCondominium,
      'listedPrice': double.tryParse(_form.price ?? '0') ?? 0.0,
      'amenities': amenityNames,
    };
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _aiSubscription?.cancel();
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
  // Tipos de vialidad reconocidos: si el input ya empieza con alguno, se
  // manda tal cual; si no, se antepone "Calle " para dar contexto al
  // geocodificador (que espera una vialidad, no solo el nombre).
  static const _streetTypes = [
    'calle',
    'avenida',
    'av',
    'cerrada',
    'privada',
    'priv',
    'boulevard',
    'blvd',
    'calzada',
    'calz',
    'callejon',
    'callejón',
    'andador',
    'circuito',
    'camino',
    'carretera',
    'prolongacion',
    'prolongación',
    'diagonal',
    'eje',
    'retorno',
    'pasaje',
    'peatonal',
    'via',
    'vía',
  ];

  String _streetQuery(String street) {
    final normalized = street
        .trim()
        .toLowerCase()
        .replaceAll('.', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final firstWord = normalized.split(' ').first;
    if (_streetTypes.contains(firstWord)) return street.trim();
    return 'Calle ${street.trim()}';
  }

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
          street: _streetQuery(street),
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
      _aiCallTimestamps.clear(); // nueva publicación, contador IA se reinicia
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
      // No pisar el formulario si el usuario entró a un modo de edición
      // mientras la subida seguía corriendo en background.
      if (_mode == PropertyFormMode.create) {
        _form = const NewPropertyForm();
        _neighborhoods = [];
        _neighborhoodsStatus = NeighborhoodsStatus.idle;
      }
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
      'street': InputSanitizer.singleLine(_form.street ?? ''),
      'exteriorNumber': InputSanitizer.singleLine(_form.exteriorNumber ?? ''),
      if (_form.interiorNumber != null && _form.interiorNumber!.isNotEmpty)
        'interiorNumber': InputSanitizer.singleLine(_form.interiorNumber!),
      'isAvailableToRent': _form.isAvailableToRent,
      'title': InputSanitizer.singleLine(_form.title ?? ''),
      'description': InputSanitizer.multiLine(_form.description ?? ''),
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

  // Body del PATCH /properties/{id}: a diferencia del draft, la dirección va
  // anidada en `address` y los campos omitidos no se modifican en el backend.
  Map<String, dynamic> _buildPatchBody() {
    return {
      'title': InputSanitizer.singleLine(_form.title ?? ''),
      'description': InputSanitizer.multiLine(_form.description ?? ''),
      'areaM2': double.tryParse(_form.area ?? '0') ?? 0.0,
      'bedrooms': _form.rooms ?? 0,
      'bathrooms': (_form.bathrooms ?? 0).toDouble(),
      'parkingSpaces': _form.parkingSpots ?? 0,
      if (_form.constructionYear != null)
        'constructionYear': _form.constructionYear,
      'isCondominium': _form.isCondominium,
      'isAvailableToRent': _form.isAvailableToRent,
      'listedPrice': double.tryParse(_form.price ?? '0') ?? 0.0,
      if (_form.propertyType != null)
        'propertyTypeId': _form.propertyType!.id,
      // Reemplazo total: siempre viaja la lista completa de amenidades.
      'amenityIds': _form.amenityIds,
      'address': {
        if (_form.neighborhood != null)
          'neighborhoodId': _form.neighborhood!.id,
        'street': InputSanitizer.singleLine(_form.street ?? ''),
        'exteriorNumber': InputSanitizer.singleLine(_form.exteriorNumber ?? ''),
        if (_form.interiorNumber != null && _form.interiorNumber!.isNotEmpty)
          'interiorNumber': InputSanitizer.singleLine(_form.interiorNumber!),
        // Solo si el usuario cambió la dirección y el geocoding (o el pin
        // manual) resolvió; omitidas, el backend conserva las actuales.
        if (_publishPoint != null) ...{
          'latitude': _publishPoint!.lat,
          'longitude': _publishPoint!.lon,
        },
      },
    };
  }
}

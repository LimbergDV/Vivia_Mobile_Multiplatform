import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Endpoints del servicio propio ViVia Maps (geocoding + basemap vectorial).
/// No requiere autenticación — nunca consumir con AuthHttpClient.
class MapsApiConstants {
  MapsApiConstants._();

  static String get baseUrl =>
      (dotenv.env['MAPS_BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');

  static String get geocode => '$baseUrl/geocode';
  static String get styleUrl => '$baseUrl/style.json';
}

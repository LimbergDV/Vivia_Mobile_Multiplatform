import 'package:http/http.dart' as http;

import 'package:vivia_mobile/features/maps/data/datasources/remote/constants/maps_api_constants.dart';

class MapStyleLoader {
  MapStyleLoader._();

  static final RegExp _mapsHost = RegExp(r'https?://[^/"]+/api/maps');
  static String? _cached;

  static Future<String> resolve() async {
    final cached = _cached;
    if (cached != null) return cached;
    try {
      final res = await http
          .get(Uri.parse(MapsApiConstants.styleUrl))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return _cached =
            res.body.replaceAll(_mapsHost, MapsApiConstants.baseUrl);
      }
    } catch (_) {}
    return MapsApiConstants.styleUrl;
  }
}

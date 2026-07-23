class FullProfileModel {
  final String name;
  final String paternalSurname;
  final String maternalSurname;
  final String email;
  final String? photoUrl;
  final String verificationStatus;
  final String? phoneNumber;
  final double? latitude;
  final double? longitude;

  const FullProfileModel({
    required this.name,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.email,
    required this.verificationStatus,
    this.photoUrl,
    this.phoneNumber,
    this.latitude,
    this.longitude,
  });

  factory FullProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return FullProfileModel(
      name: data['name'] as String? ?? '',
      paternalSurname: data['paternalSurname'] as String? ?? '',
      maternalSurname: data['maternalSurname'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: _string(data, ['photoUrl', 'profilePhotoUrl', 'avatarUrl', 'photo']),
      verificationStatus: data['verificationStatus'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String?,
      latitude: _coord(data, ['latitude', 'lat']),
      longitude: _coord(data, ['longitude', 'lng', 'lon', 'long']),
    );
  }

  static const _coordContainers = ['ubication', 'location', 'coordinates', 'coords'];

  static double? _coord(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is num) return value.toDouble();
    }
    for (final container in _coordContainers) {
      final nested = data[container];
      if (nested is Map<String, dynamic>) {
        final value = _coord(nested, keys);
        if (value != null) return value;
      }
    }
    return null;
  }

  static String? _string(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}

class FullProfileModel {
  final String name;
  final String paternalSurname;
  final String maternalSurname;
  final String email;
  final String? photoUrl;
  final String verificationStatus;

  const FullProfileModel({
    required this.name,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.email,
    required this.verificationStatus,
    this.photoUrl,
  });

  factory FullProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return FullProfileModel(
      name: data['name'] as String? ?? '',
      paternalSurname: data['paternalSurname'] as String? ?? '',
      maternalSurname: data['maternalSurname'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      verificationStatus: data['verificationStatus'] as String? ?? '',
    );
  }
}

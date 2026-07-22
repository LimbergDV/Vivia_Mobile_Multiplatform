import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:vivia_mobile/features/auth/domain/usecases/put_ubication_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_email_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_name_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_password_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_phone_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_profile_photo_usecase.dart';

class PersonalInfoViewModel extends ChangeNotifier {
  final UpdateNameUseCase _updateNameUseCase;
  final UpdateEmailUseCase _updateEmailUseCase;
  final UpdatePhoneUseCase _updatePhoneUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;
  final UpdateProfilePhotoUseCase _updateProfilePhotoUseCase;
  final PutUbicationUseCase _putUbicationUseCase;

  String _firstName;
  String _paternalSurname;
  String _maternalSurname;
  String _email;
  String? _phone;
  String? _avatarUrl;
  final bool _isLessor;
  final bool _isVerified;
  bool _hasLocation;
  bool _isUploadingPhoto = false;
  bool _isUpdatingLocation = false;

  PersonalInfoViewModel({
    required UpdateNameUseCase updateNameUseCase,
    required UpdateEmailUseCase updateEmailUseCase,
    required UpdatePhoneUseCase updatePhoneUseCase,
    required UpdatePasswordUseCase updatePasswordUseCase,
    required UpdateProfilePhotoUseCase updateProfilePhotoUseCase,
    required PutUbicationUseCase putUbicationUseCase,
    required String firstName,
    required String paternalSurname,
    required String maternalSurname,
    required String email,
    required bool isLessor,
    bool isVerified = false,
    bool hasLocation = false,
    String? phone,
    String? avatarUrl,
  })  : _updateNameUseCase = updateNameUseCase,
        _updateEmailUseCase = updateEmailUseCase,
        _updatePhoneUseCase = updatePhoneUseCase,
        _updatePasswordUseCase = updatePasswordUseCase,
        _updateProfilePhotoUseCase = updateProfilePhotoUseCase,
        _putUbicationUseCase = putUbicationUseCase,
        _firstName = firstName,
        _paternalSurname = paternalSurname,
        _maternalSurname = maternalSurname,
        _email = email,
        _isLessor = isLessor,
        _isVerified = isVerified,
        _hasLocation = hasLocation,
        _phone = phone,
        _avatarUrl = avatarUrl;

  String get firstName => _firstName;
  String get paternalSurname => _paternalSurname;
  String get maternalSurname => _maternalSurname;
  String get email => _email;
  String? get phone => _phone;
  String? get avatarUrl => _avatarUrl;
  String get fullName => [_firstName, _paternalSurname, _maternalSurname]
      .where((part) => part.isNotEmpty)
      .join(' ');
  bool get isUploadingPhoto => _isUploadingPhoto;
  bool get isUpdatingLocation => _isUpdatingLocation;

  List<bool> get _completionChecklist => [
        _firstName.trim().isNotEmpty,
        _paternalSurname.trim().isNotEmpty,
        _email.trim().isNotEmpty,
        _avatarUrl?.isNotEmpty ?? false,
        _isLessor ? (_phone?.trim().isNotEmpty ?? false) : _hasLocation,
        if (_isLessor) _isVerified,
      ];

  double get completionPercent {
    final items = _completionChecklist;
    return items.where((done) => done).length / items.length;
  }

  /// PATCH /users/me/name
  Future<void> updateName({
    required String name,
    required String paternalSurname,
    required String maternalSurname,
  }) async {
    await _updateNameUseCase.execute(
      name: name.trim(),
      paternalSurname: paternalSurname.trim(),
      maternalSurname: maternalSurname.trim(),
    );
    _firstName = name.trim();
    _paternalSurname = paternalSurname.trim();
    _maternalSurname = maternalSurname.trim();
    notifyListeners();
  }

  /// PATCH /users/me/email
  Future<void> updateEmail(String value) async {
    await _updateEmailUseCase.execute(value.trim());
    _email = value.trim();
    notifyListeners();
  }

  /// PATCH /users/me/phone (solo lessor)
  Future<void> updatePhone(String value) async {
    await _updatePhoneUseCase.execute(value.trim());
    _phone = value.trim();
    notifyListeners();
  }

  /// PATCH /auth/me/password
  Future<void> updatePassword(String password) =>
      _updatePasswordUseCase.execute(password);

  /// PUT /users/me/photo (presign) + PUT del binario a S3.
  Future<void> updatePhoto({
    required Uint8List bytes,
    required String contentType,
  }) async {
    _isUploadingPhoto = true;
    notifyListeners();
    try {
      final photoUrl = await _updateProfilePhotoUseCase.execute(
        bytes: bytes,
        contentType: contentType,
      );
      // Cache-buster: la URL pública es estable, sin esto la imagen
      // anterior seguiría mostrándose desde el caché.
      _avatarUrl = '$photoUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } finally {
      _isUploadingPhoto = false;
      notifyListeners();
    }
  }

  /// PUT /lessees/ubication — pide permiso, obtiene GPS y envía coordenadas.
  Future<void> updateUbication() async {
    _isUpdatingLocation = true;
    notifyListeners();
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Permiso de ubicación denegado');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      await _putUbicationUseCase.execute(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _hasLocation = true;
    } finally {
      _isUpdatingLocation = false;
      notifyListeners();
    }
  }
}

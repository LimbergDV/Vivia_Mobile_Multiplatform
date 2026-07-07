import 'package:flutter/material.dart';

class PersonalInfoViewModel extends ChangeNotifier {
  String _firstName;
  String _lastName;
  String _email;
  String? _phone;
  String? _location;
  String? _avatarUrl;

  PersonalInfoViewModel({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? location,
    String? avatarUrl,
  })  : _firstName = firstName,
        _lastName = lastName,
        _email = email,
        _phone = phone,
        _location = location,
        _avatarUrl = avatarUrl;

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String? get phone => _phone;
  String? get location => _location;
  String? get avatarUrl => _avatarUrl;
  String get fullName => '$_firstName $_lastName'.trim();

  void updateName({required String first, required String last}) {
    _firstName = first.trim();
    _lastName = last.trim();
    notifyListeners();
  }

  void updateEmail(String value) {
    _email = value.trim();
    notifyListeners();
  }

  void updatePhone(String value) {
    _phone = value.trim();
    notifyListeners();
  }

  void updateLocation(String value) {
    _location = value.trim();
    notifyListeners();
  }

  void updateAvatar(String url) {
    _avatarUrl = url;
    notifyListeners();
  }
}
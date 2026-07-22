import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/login_google_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/register_lessee_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/register_lessor_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/register_lessee_google_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/register_lessor_google_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/register_fcm_token_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/set_location_permission_shown_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/put_ubication_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LoginGoogleUseCase _loginGoogleUseCase;
  final RegisterLesseeUseCase _registerLesseeUseCase;
  final RegisterLessorUseCase _registerLessorUseCase;
  final RegisterLesseeGoogleUseCase _registerLesseeGoogleUseCase;
  final RegisterLessorGoogleUseCase _registerLessorGoogleUseCase;
  final LogoutUseCase _logoutUseCase;
  final SetLocationPermissionShownUseCase _setLocationPermissionShownUseCase;
  final PutUbicationUseCase _putUbicationUseCase;
  final AuthRepository _authRepository;
  final RegisterFcmTokenUseCase _registerFcmTokenUseCase;
  final VoidCallback? _onSessionCleared;

  AuthViewModel({
    required LoginUseCase loginUseCase,
    required LoginGoogleUseCase loginGoogleUseCase,
    required RegisterLesseeUseCase registerLesseeUseCase,
    required RegisterLessorUseCase registerLessorUseCase,
    required RegisterLesseeGoogleUseCase registerLesseeGoogleUseCase,
    required RegisterLessorGoogleUseCase registerLessorGoogleUseCase,
    required LogoutUseCase logoutUseCase,
    required SetLocationPermissionShownUseCase setLocationPermissionShownUseCase,
    required PutUbicationUseCase putUbicationUseCase,
    required AuthRepository authRepository,
    required RegisterFcmTokenUseCase registerFcmTokenUseCase,
    VoidCallback? onSessionCleared,
  })  : _loginUseCase = loginUseCase,
        _loginGoogleUseCase = loginGoogleUseCase,
        _registerLesseeUseCase = registerLesseeUseCase,
        _registerLessorUseCase = registerLessorUseCase,
        _registerLesseeGoogleUseCase = registerLesseeGoogleUseCase,
        _registerLessorGoogleUseCase = registerLessorGoogleUseCase,
        _logoutUseCase = logoutUseCase,
        _registerFcmTokenUseCase = registerFcmTokenUseCase,
        _setLocationPermissionShownUseCase = setLocationPermissionShownUseCase,
        _putUbicationUseCase = putUbicationUseCase,
        _authRepository = authRepository,
        _onSessionCleared = onSessionCleared;

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;

  String _userName = '';
  String? _avatarUrl;
  UserRole _lastRole = UserRole.lessee;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get userName => _userName;
  String? get avatarUrl => _avatarUrl;
  UserRole get lastRole => _lastRole;
  bool get hasSeenLocationPermission => _authRepository.hasSeenLocationPermission;

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    if (e is SocketException ||
        e is TimeoutException ||
        e is http.ClientException) {
      return 'Sin conexión a internet. Revisa tu red e intenta de nuevo.';
    }
    return e.toString().replaceFirst('Exception: ', '');
  }

  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  bool _loginPasswordVisible = false;
  bool get loginPasswordVisible => _loginPasswordVisible;

  void toggleLoginPasswordVisibility() {
    _loginPasswordVisible = !_loginPasswordVisible;
    notifyListeners();
  }

  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerLastNameController =
  TextEditingController();
  final TextEditingController registerMaternalSurnameController =
  TextEditingController();
  final TextEditingController registerPhoneController = TextEditingController();
  final TextEditingController registerPasswordController =
  TextEditingController();
  final TextEditingController registerConfirmPasswordController =
  TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  bool _registerPasswordVisible = false;
  bool _registerConfirmPasswordVisible = false;
  bool get registerPasswordVisible => _registerPasswordVisible;
  bool get registerConfirmPasswordVisible => _registerConfirmPasswordVisible;

  void toggleRegisterPasswordVisibility() {
    _registerPasswordVisible = !_registerPasswordVisible;
    notifyListeners();
  }

  void toggleRegisterConfirmPasswordVisibility() {
    _registerConfirmPasswordVisible = !_registerConfirmPasswordVisible;
    notifyListeners();
  }

  Future<void> login(UserRole role) async {
    if (!loginFormKey.currentState!.validate()) return;
    _setLoading();
    try {
      final result = await _loginUseCase.execute(
        loginEmailController.text.trim(),
        loginPasswordController.text,
      );

      final expectedRole = role == UserRole.lessee ? 'ROLE_LESSEE' : 'ROLE_LESSOR';

      if (result.role != expectedRole) {
        _status = AuthStatus.error;
        _errorMessage = role == UserRole.lessee
            ? 'Esta cuenta no es de arrendatario'
            : 'Esta cuenta no es de arrendador';
        notifyListeners();
        return;
      }

      _userName = result.name;
      _lastRole = role;
      _avatarUrl = null;
      _status = AuthStatus.success;
      _registerFcmTokenUseCase.execute().ignore();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _friendlyError(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> register(UserRole role) async {
    if (!registerFormKey.currentState!.validate()) return;
    _setLoading();
    try {
      final name = registerNameController.text.trim();
      final paternalSurname = registerLastNameController.text.trim();

      if (role == UserRole.lessee) {
        await _registerLesseeUseCase.execute(
          name: name,
          paternalSurname: paternalSurname,
          maternalSurname: registerMaternalSurnameController.text.trim(),
          email: registerEmailController.text.trim(),
          password: registerPasswordController.text,
        );
      } else {
        await _registerLessorUseCase.execute(
          name: name,
          paternalSurname: paternalSurname,
          maternalSurname: registerMaternalSurnameController.text.trim(),
          email: registerEmailController.text.trim(),
          phoneNumber: registerPhoneController.text.trim(),
          password: registerPasswordController.text,
        );
      }
      _userName = name;
      _lastRole = role;
      _avatarUrl = null;
      _status = AuthStatus.success;
      _registerFcmTokenUseCase.execute().ignore();
      _clearRegisterFields();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _friendlyError(e);
    } finally {
      notifyListeners();
    }
  }

  void _clearRegisterFields() {
    registerNameController.clear();
    registerLastNameController.clear();
    registerMaternalSurnameController.clear();
    registerPhoneController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
    registerEmailController.clear();
  }

  Future<void> loginWithGoogle(UserRole role) async {
    _setLoading();
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '',
      );
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _status = AuthStatus.idle;
        notifyListeners();
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken ?? '';
      final displayName = googleUser.displayName ?? googleUser.email.split('@').first;
      final photoUrl = googleUser.photoUrl;

      try {
        await _loginGoogleUseCase.execute(
          idToken: idToken,
          role: role,
          displayName: displayName,
          avatarUrl: photoUrl,
        );
      } catch (e) {
        if (e is TimeoutException || e is SocketException || e is http.ClientException) rethrow;
        if (role == UserRole.lessee) {
          await _registerLesseeGoogleUseCase.execute(
            idToken: idToken,
            displayName: displayName,
            avatarUrl: photoUrl,
          );
        } else {
          await _registerLessorGoogleUseCase.execute(
            idToken: idToken,
            displayName: displayName,
            avatarUrl: photoUrl,
          );
        }
      }
      _userName = displayName.split(' ').first;
      _lastRole = role;
      _avatarUrl = photoUrl;
      _status = AuthStatus.success;
      _registerFcmTokenUseCase.execute().ignore();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _friendlyError(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _setLoading();
    try {
      await _logoutUseCase.execute();
      _userName = '';
      _avatarUrl = null;
      _status = AuthStatus.idle;
      _clearRegisterFields();
      _onSessionCleared?.call();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _friendlyError(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> syncFcmToken() => _registerFcmTokenUseCase.execute();

  void resetStatus() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void handleSessionExpired() {
    _userName = '';
    _avatarUrl = null;
    _status = AuthStatus.idle;
    _clearRegisterFields();
    notifyListeners();
    _onSessionCleared?.call();
  }

  Future<void> markLocationPermissionShown() =>
      _setLocationPermissionShownUseCase.execute();

  void putUbicationFireAndForget(double latitude, double longitude) {
    _putUbicationUseCase
        .execute(latitude: latitude, longitude: longitude)
        .catchError((_) {});
  }

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerLastNameController.dispose();
    registerMaternalSurnameController.dispose();
    registerPhoneController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    registerEmailController.dispose();
    super.dispose();
  }
}
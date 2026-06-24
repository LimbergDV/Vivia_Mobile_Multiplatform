import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/login_google_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/register_lessee_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/register_lessor_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/register_lessee_google_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/register_lessor_google_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/logout_usecase.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LoginGoogleUseCase _loginGoogleUseCase;
  final RegisterLesseeUseCase _registerLesseeUseCase;
  final RegisterLessorUseCase _registerLessorUseCase;
  final RegisterLesseeGoogleUseCase _registerLesseeGoogleUseCase;
  final RegisterLessorGoogleUseCase _registerLessorGoogleUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthViewModel({
    required LoginUseCase loginUseCase,
    required LoginGoogleUseCase loginGoogleUseCase,
    required RegisterLesseeUseCase registerLesseeUseCase,
    required RegisterLessorUseCase registerLessorUseCase,
    required RegisterLesseeGoogleUseCase registerLesseeGoogleUseCase,
    required RegisterLessorGoogleUseCase registerLessorGoogleUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _loginGoogleUseCase = loginGoogleUseCase,
        _registerLesseeUseCase = registerLesseeUseCase,
        _registerLessorUseCase = registerLessorUseCase,
        _registerLesseeGoogleUseCase = registerLesseeGoogleUseCase,
        _registerLessorGoogleUseCase = registerLessorGoogleUseCase,
        _logoutUseCase = logoutUseCase;

  // ── Estado ────────────────────────────────────────────────────────────
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Controllers de Login ──────────────────────────────────────────────
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  bool _loginPasswordVisible = false;
  bool get loginPasswordVisible => _loginPasswordVisible;

  void toggleLoginPasswordVisibility() {
    _loginPasswordVisible = !_loginPasswordVisible;
    notifyListeners();
  }

  // ── Controllers de Registro ───────────────────────────────────────────
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

  // ── Login con contraseña ──────────────────────────────────────────────
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;
    _setLoading();
    try {
      await _loginUseCase.execute(
        loginEmailController.text.trim(),
        loginPasswordController.text,
      );
      _status = AuthStatus.success;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  // ── Registro ──────────────────────────────────────────────────────────
  Future<void> register(UserRole role) async {
    if (!registerFormKey.currentState!.validate()) return;
    _setLoading();
    try {
      if (role == UserRole.lessee) {
        await _registerLesseeUseCase.execute(
          name: registerNameController.text.trim(),
          paternalSurname: registerLastNameController.text.trim(),
          maternalSurname: registerMaternalSurnameController.text.trim(),
          email: registerEmailController.text.trim(),
          password: registerPasswordController.text,
        );
      } else {
        await _registerLessorUseCase.execute(
          name: registerNameController.text.trim(),
          paternalSurname: registerLastNameController.text.trim(),
          maternalSurname: registerMaternalSurnameController.text.trim(),
          email: registerEmailController.text.trim(),
          phoneNumber: registerPhoneController.text.trim(),
          password: registerPasswordController.text,
        );
      }
      _status = AuthStatus.success;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  // ── Login / Registro con Google ───────────────────────────────────────
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

      try {
        await _loginGoogleUseCase.execute(idToken, role);
      } catch (_) {
        if (role == UserRole.lessee) {
          await _registerLesseeGoogleUseCase.execute(idToken);
        } else {
          await _registerLessorGoogleUseCase.execute(idToken);
        }
      }
      _status = AuthStatus.success;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────
  Future<void> logout() async {
    _setLoading();
    try {
      await _logoutUseCase.execute();
      _status = AuthStatus.idle;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  // ── Resetear estado ───────────────────────────────────────────────────
  void resetStatus() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
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

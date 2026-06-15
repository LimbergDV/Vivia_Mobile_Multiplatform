import 'package:flutter/material.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

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
  final TextEditingController registerLastNameController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();
  final TextEditingController registerConfirmPasswordController = TextEditingController();
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

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // TODO: Conectar con el UseCase de login
    await Future.delayed(const Duration(seconds: 2)); // simulación

    _status = AuthStatus.success;
    notifyListeners();
  }

  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // TODO: Conectar con el UseCase de registro
    await Future.delayed(const Duration(seconds: 2)); // simulación

    _status = AuthStatus.success;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    _status = AuthStatus.loading;
    notifyListeners();

    // TODO: Conectar con Google Sign-In
    await Future.delayed(const Duration(seconds: 1));

    _status = AuthStatus.idle;
    notifyListeners();
  }

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
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    registerEmailController.dispose();
    super.dispose();
  }
}
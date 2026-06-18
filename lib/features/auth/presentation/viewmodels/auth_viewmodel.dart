import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vivia_mobile/core/network/dio_client.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  String? _token;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get token => _token;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

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
  final TextEditingController registerPhoneController = TextEditingController();
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

    try {
      final response = await DioClient.instance.post('/auth/login', data: {
        'identifier': loginEmailController.text,
        'password': loginPasswordController.text,
      });

      _token = response.data['data']?['accessToken'] ?? response.data['data']?['token'];
      _status = AuthStatus.success;
    } on DioException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.response?.data['message'] ?? 'Error al iniciar sesión';
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Ocurrió un error inesperado';
    } finally {
      notifyListeners();
    }
  }

  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    _status = AuthStatus.loading;
    _errorMessage = null;
    _token = null;
    notifyListeners();

    try {
      // Dividimos el apellido en paterno y materno (simplificado)
      final names = registerLastNameController.text.split(' ');
      final paternal = names.isNotEmpty ? names[0] : '';
      final maternal = names.length > 1 ? names.sublist(1).join(' ') : '';

      final response = await DioClient.instance.post('/lessors/password', data: {
        'name': registerNameController.text,
        'paternalSurname': paternal,
        'maternalSurname': maternal,
        'email': registerEmailController.text,
        'password': registerPasswordController.text,
        'phoneNumber': registerPhoneController.text,
      });

      _token = response.data['data']?['accessToken'] ?? response.data['data']?['token'];
      _status = AuthStatus.success;
    } on DioException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.response?.data['message'] ?? 'Error al registrarse: ${e.message}';
      print('DioError: ${e.response?.data}');
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Ocurrió un error inesperado: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> registerWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _token = null;
    notifyListeners();

    try {
      await _googleSignIn.initialize(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
      
      if (googleUser == null) {
        _status = AuthStatus.idle;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _status = AuthStatus.error;
        _errorMessage = 'No se pudo obtener el ID Token de Google';
        notifyListeners();
        return;
      }

      // Endpoint específico para REGISTRO de LESSOR
      final response = await DioClient.instance.post('/lessors/google', data: {
        'idToken': idToken,
      });

      _token = response.data['data']?['accessToken'] ?? response.data['data']?['token'];
      _status = AuthStatus.success;
    } on DioException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.response?.data['message'] ?? 'Error al registrar con Google: ${e.message}';
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Ocurrió un error inesperado: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _token = null;
    notifyListeners();

    try {
      // En la versión 7.2.0+, initialize() requiere serverClientId para Android
      await _googleSignIn.initialize(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
      if (googleUser == null) {
        _status = AuthStatus.idle;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _status = AuthStatus.error;
        _errorMessage = 'No se pudo obtener el ID Token de Google';
        notifyListeners();
        return;
      }

      final response = await DioClient.instance.post('/auth/login/google', data: {
        'idToken': idToken,
        'role': 'ROLE_LESSOR',
      });

      _token = response.data['data']?['accessToken'] ?? response.data['data']?['token'];
      _status = AuthStatus.success;
    } on DioException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.response?.data['message'] ?? 'Error al autenticar con Google: ${e.message}';
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Ocurrió un error inesperado: $e';
    } finally {
      notifyListeners();
    }
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
    registerPhoneController.dispose();
    super.dispose();
  }
}
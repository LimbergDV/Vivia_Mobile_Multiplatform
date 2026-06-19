import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:vivia_mobile/core/network/dio_client.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'package:vivia_mobile/features/auth/data/models/biometric_challenge_response.dart';
import 'package:vivia_mobile/features/auth/data/models/biometric_auth_response.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  String? _token;
  String? _debugMessage; // Para mostrar mensajes de debug en la UI

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  String? get debugMessage => _debugMessage;

  void _setDebugMessage(String message) {
    _debugMessage = message;
    print('DEBUG: $message');
    notifyListeners();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final PasskeyAuthenticator _passkeyAuthenticator = PasskeyAuthenticator();

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

  Future<void> loginWithBiometrics() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _token = null;
    _debugMessage = null;
    notifyListeners();

    try {
      // Paso 1: Verificar biometría del dispositivo
      _setDebugMessage('Paso 1/4: Verificando biometría del dispositivo...');
      final bool canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        _status = AuthStatus.error;
        _errorMessage = 'La autenticación biométrica no está disponible en este dispositivo.\n\n'
            'Asegúrate de tener configurada la huella digital o reconocimiento facial.';
        notifyListeners();
        return;
      }

      // Paso 2: Validar que haya email ingresado
      if (loginEmailController.text.isEmpty) {
        _status = AuthStatus.error;
        _errorMessage = 'Por favor ingresa tu correo electrónico antes de usar la huella digital.';
        notifyListeners();
        return;
      }

      // Paso 3: Solicitar challenge del servidor con el email
      _setDebugMessage('Paso 2/4: Solicitando challenge al servidor...');

      Response challengeResponse;
      try {
        challengeResponse = await DioClient.instance.post(
          '/auth/login/challenge',
          data: {
            'email': loginEmailController.text,
          },
        );
        _setDebugMessage('Respuesta del servidor recibida');

        print('=== RESPUESTA LOGIN CHALLENGE ===');
        print('Status: ${challengeResponse.statusCode}');
        print('Data: ${challengeResponse.data}');
        print('==================================');
      } catch (e) {
        _status = AuthStatus.error;
        if (e is DioException) {
          _errorMessage = 'Error al solicitar challenge de login:\n'
              'Código: ${e.response?.statusCode}\n'
              'Mensaje: ${e.response?.data}\n'
              'Error: ${e.message}';
        } else {
          _errorMessage = 'Error de red al solicitar challenge: $e';
        }
        notifyListeners();
        return;
      }

      // Parsear la respuesta del challenge
      BiometricChallengeResponse challengeData;
      try {
        challengeData = BiometricChallengeResponse.fromJson(challengeResponse.data);
      } catch (e, stackTrace) {
        _status = AuthStatus.error;
        _errorMessage = 'Error parseando respuesta del servidor:\n$e\n\nStackTrace:\n$stackTrace';
        print('>>> ERROR en parseo de login challenge: $e');
        notifyListeners();
        return;
      }

      if (!challengeData.success || challengeData.data.isEmpty) {
        _status = AuthStatus.error;
        _errorMessage = 'El servidor no devolvió un challenge válido:\n'
            'Success: ${challengeData.success}\n'
            'Message: ${challengeData.message}';
        notifyListeners();
        return;
      }

      _setDebugMessage('Challenge de login recibido: ${challengeData.message}');

      // Paso 3: Autenticar con la credencial biométrica
      _setDebugMessage('Paso 3/4: Autenticando con huella digital...\nPor favor, usa tu huella digital');

      AuthenticateRequestType authenticateRequest;
      try {
        final publicKeyJson = challengeData.getPublicKeyAsJsonString();
        print('=== PUBLIC KEY JSON PARA LOGIN ===');
        print(publicKeyJson);
        print('==================================');

        authenticateRequest = AuthenticateRequestType.fromJsonString(publicKeyJson);
        _setDebugMessage('Challenge parseado correctamente');
      } catch (e, stackTrace) {
        _status = AuthStatus.error;
        _errorMessage = 'Error parseando challenge de login: $e\n\nStackTrace: $stackTrace';
        print('ERROR parseando challenge de login: $e');
        print('StackTrace: $stackTrace');
        notifyListeners();
        return;
      }

      AuthenticateResponseType credentialResponse;
      try {
        credentialResponse = await _passkeyAuthenticator.authenticate(authenticateRequest);
        _setDebugMessage('Autenticación biométrica exitosa');
      } catch (e) {
        _status = AuthStatus.error;
        _errorMessage = 'Error al autenticar con biometría: $e\n\n'
            'Posibles causas:\n'
            '- No tienes credenciales registradas\n'
            '- La huella no coincide\n'
            '- Cancelaste la autenticación';
        print('Error en autenticación: $e');
        notifyListeners();
        return;
      }

      // Paso 4: Verificar con el servidor
      _setDebugMessage('Paso 4/4: Verificando con el servidor...');

      try {
        final credentialJson = credentialResponse.toJsonString();
        print('=== CREDENTIAL JSON LOGIN A ENVIAR ===');
        print(credentialJson);
        print('=======================================');

        final verifyResponse = await DioClient.instance.post(
          '/auth/login/verify',
          data: {
            'credentialResponseJson': credentialJson,
          },
        );

        print('=== RESPUESTA DE VERIFICACIÓN LOGIN ===');
        print('Status: ${verifyResponse.statusCode}');
        print('Data: ${verifyResponse.data}');
        print('========================================');

        final authData = BiometricAuthResponse.fromJson(verifyResponse.data);

        if (!authData.success || authData.data.accessToken.isEmpty) {
          _status = AuthStatus.error;
          _errorMessage = authData.message.isNotEmpty
              ? authData.message
              : 'Error al verificar la credencial de login';
          notifyListeners();
          return;
        }

        _token = authData.data.accessToken;
        _status = AuthStatus.success;
        _setDebugMessage('¡Login completado exitosamente!');
      } on DioException catch (e) {
        _status = AuthStatus.error;
        print('=== ERROR DE VERIFICACIÓN LOGIN (DioException) ===');
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Error Message: ${e.message}');
        print('===================================================');

        final errorMessage = e.response?.data is Map
            ? (e.response?.data['message'] ?? e.response?.data['error'] ?? e.response?.data.toString())
            : e.response?.data?.toString() ?? e.message;

        _errorMessage = 'Error al verificar login (${e.response?.statusCode}):\n$errorMessage';
        notifyListeners();
        return;
      } catch (e) {
        _status = AuthStatus.error;
        _errorMessage = 'Error inesperado al verificar login: $e';
        print('=== ERROR INESPERADO LOGIN ===');
        print('Error: $e');
        print('===============================');
        notifyListeners();
        return;
      }

    } on DioException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.response?.data['message'] ?? 'Error en el login biométrico: ${e.message}';
      print('DioError en login biométrico: ${e.response?.data}');
    } on PlatformException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Error de plataforma en login biométrico: ${e.message}\n\nCódigo: ${e.code}';
      print('PlatformException en login: $e');
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Error inesperado en login biométrico: $e';
      print('Error inesperado en login biométrico: $e');
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
      // Dividimos el apellido en paterno y materno
      final names = registerLastNameController.text.trim().split(' ');
      final paternal = names.isNotEmpty ? names[0] : '';
      // Si no hay apellido materno, usar el paterno o un valor por defecto
      final maternal = names.length > 1 ? names.sublist(1).join(' ') : (paternal.isNotEmpty ? paternal : 'N/A');

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

  Future<void> registerWithBiometrics() async {
    if (!registerFormKey.currentState!.validate()) return;

    _status = AuthStatus.loading;
    _errorMessage = null;
    _token = null;
    _debugMessage = null;
    notifyListeners();

    try {
      _setDebugMessage('Paso 1/5: Verificando biometría del dispositivo...');

      // Verificar si el dispositivo soporta biometría
      final bool canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        _status = AuthStatus.error;
        _errorMessage = 'La autenticación biométrica no está disponible en este dispositivo.';
        notifyListeners();
        return;
      }

      _setDebugMessage('Paso 2/5: Solicitando challenge al servidor...');

      // Dividimos el apellido en paterno y materno
      final names = registerLastNameController.text.trim().split(' ');
      final paternal = names.isNotEmpty ? names[0] : '';
      // Si no hay apellido materno, usar el paterno o un valor por defecto
      final maternal = names.length > 1 ? names.sublist(1).join(' ') : (paternal.isNotEmpty ? paternal : 'N/A');

      // Paso 1: Solicitar el challenge del servidor
      Response challengeResponse;
      try {
        challengeResponse = await DioClient.instance.post(
          '/lessors/biometric/challenge',
          data: {
            'email': registerEmailController.text,
            'name': registerNameController.text,
            'paternalSurname': paternal,
            'maternalSurname': maternal,
            'phoneNumber': registerPhoneController.text,
          },
        );
        _setDebugMessage('Respuesta del servidor recibida');

        // Log de la respuesta RAW completa
        print('=== RESPUESTA RAW DEL SERVIDOR ===');
        print('Status: ${challengeResponse.statusCode}');
        print('Headers: ${challengeResponse.headers}');
        print('Data type: ${challengeResponse.data.runtimeType}');
        print('Data completo: ${challengeResponse.data}');
        print('===================================');
      } catch (e) {
        _status = AuthStatus.error;
        if (e is DioException) {
          _errorMessage = 'Error al solicitar challenge:\n'
              'Código: ${e.response?.statusCode}\n'
              'Mensaje: ${e.response?.data}\n'
              'Error: ${e.message}';
        } else {
          _errorMessage = 'Error de red al solicitar challenge: $e';
        }
        notifyListeners();
        return;
      }

      print('>>> Iniciando parseo de BiometricChallengeResponse...');
      BiometricChallengeResponse challengeData;
      try {
        print('>>> Intentando parsear challengeResponse.data...');
        challengeData = BiometricChallengeResponse.fromJson(challengeResponse.data);
        print('>>> Parseo exitoso!');
      } catch (e, stackTrace) {
        _status = AuthStatus.error;
        _errorMessage = 'Error parseando respuesta del servidor:\n$e\n\nStackTrace:\n$stackTrace\n\nRespuesta: ${challengeResponse.data}';
        print('>>> ERROR en parseo: $e');
        print('>>> StackTrace: $stackTrace');
        notifyListeners();
        return;
      }

      print('>>> Validando challengeData...');
      print('>>> challengeData.success: ${challengeData.success}');
      print('>>> challengeData.data.isEmpty: ${challengeData.data.isEmpty}');
      print('>>> challengeData.data: ${challengeData.data}');

      if (!challengeData.success || challengeData.data.isEmpty) {
        _status = AuthStatus.error;
        _errorMessage = 'El servidor no devolvió un challenge válido:\n'
            'Success: ${challengeData.success}\n'
            'Message: ${challengeData.message}\n'
            'Data: ${challengeData.data}';
        print('>>> Validación falló - terminando');
        notifyListeners();
        return;
      }

      print('>>> Validación exitosa');
      _setDebugMessage('Challenge recibido: ${challengeData.message}');

      // Paso 2: Crear la credencial biométrica usando el challenge
      // El backend devuelve: { "publicKey": { "rp": {...}, "user": {...}, ... } }
      // Necesitamos extraer y convertir publicKey a JSON string
      _setDebugMessage('Paso 3/5: Parseando challenge...');

      // Debug detallado del structure
      print('=== DEBUG ESTRUCTURA CHALLENGE ===');
      print('challengeData.data keys: ${challengeData.data.keys}');
      print('challengeData.data contains publicKey: ${challengeData.data.containsKey('publicKey')}');

      if (challengeData.data.containsKey('publicKey')) {
        final publicKey = challengeData.data['publicKey'];
        print('publicKey type: ${publicKey.runtimeType}');
        print('publicKey keys: ${(publicKey as Map).keys}');
        print('publicKey.rp: ${publicKey['rp']}');
        print('publicKey.user: ${publicKey['user']}');
        print('publicKey.challenge: ${publicKey['challenge']}');
      }
      print('===================================');

      RegisterRequestType registerRequest;
      try {
        final publicKeyJson = challengeData.getPublicKeyAsJsonString();
        print('=== PUBLIC KEY JSON GENERADO ===');
        print(publicKeyJson);
        print('================================');

        registerRequest = RegisterRequestType.fromJsonString(publicKeyJson);
        _setDebugMessage('Challenge parseado correctamente');
      } catch (e, stackTrace) {
        _status = AuthStatus.error;
        _errorMessage = 'Error parseando challenge: $e\n\nStackTrace: $stackTrace\n\nChallenge recibido: ${challengeData.data.toString().substring(0, 200)}...';
        print('ERROR parseando challenge: $e');
        print('StackTrace: $stackTrace');
        print('Challenge data completo: ${challengeData.data}');
        notifyListeners();
        return;
      }

      // Intentar registrar la credencial biométrica
      _setDebugMessage('Paso 4/5: Creando credencial biométrica...\nPor favor, usa tu huella digital');

      RegisterResponseType credentialResponse;
      try {
        credentialResponse = await _passkeyAuthenticator.register(registerRequest);
        _setDebugMessage('Credencial biométrica creada exitosamente');
      } catch (e) {
        _status = AuthStatus.error;
        _errorMessage = 'Error al crear la credencial biométrica: $e\n\nAsegúrate de que la biometría esté configurada.';
        print('Error al registrar credencial: $e');
        notifyListeners();
        return;
      }

      // Paso 3: Enviar la credencial al servidor para verificación y registro
      _setDebugMessage('Paso 5/5: Verificando con el servidor...');

      try {
        final credentialJson = credentialResponse.toJsonString();
        print('=== CREDENTIAL JSON A ENVIAR ===');
        print(credentialJson);
        print('================================');

        final verifyResponse = await DioClient.instance.post(
          '/lessors/biometric/verify',
          data: {
            'credentialResponseJson': credentialJson,
          },
        );

        print('=== RESPUESTA DE VERIFICACIÓN ===');
        print('Status: ${verifyResponse.statusCode}');
        print('Data: ${verifyResponse.data}');
        print('=================================');

        final authData = BiometricAuthResponse.fromJson(verifyResponse.data);

        if (!authData.success || authData.data.accessToken.isEmpty) {
          _status = AuthStatus.error;
          _errorMessage = authData.message.isNotEmpty
              ? authData.message
              : 'Error al verificar la credencial biométrica';
          notifyListeners();
          return;
        }

        _token = authData.data.accessToken;
        _status = AuthStatus.success;
        _setDebugMessage('¡Registro completado exitosamente!');
      } on DioException catch (e) {
        _status = AuthStatus.error;
        print('=== ERROR DE VERIFICACIÓN (DioException) ===');
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Error Message: ${e.message}');
        print('Error Type: ${e.type}');
        print('============================================');

        final errorMessage = e.response?.data is Map
            ? (e.response?.data['message'] ?? e.response?.data['error'] ?? e.response?.data.toString())
            : e.response?.data?.toString() ?? e.message;

        _errorMessage = 'Error al verificar con el servidor (${e.response?.statusCode}):\n$errorMessage';
        notifyListeners();
        return;
      } catch (e) {
        _status = AuthStatus.error;
        _errorMessage = 'Error inesperado al verificar con el servidor: $e';
        print('=== ERROR INESPERADO ===');
        print('Error: $e');
        print('========================');
        notifyListeners();
        return;
      }

    } on DioException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.response?.data['message'] ?? 'Error en el registro biométrico: ${e.message}';
      print('DioError en registro biométrico: ${e.response?.data}');
    } on PlatformException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Error de plataforma en el registro biométrico: ${e.message}';
      print('PlatformException: ${e.message}');
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Ocurrió un error inesperado: $e';
      print('Error inesperado: $e');
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
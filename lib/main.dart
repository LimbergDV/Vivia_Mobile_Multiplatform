import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vivia_mobile/core/http/auth_http_client.dart';
import 'package:vivia_mobile/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:vivia_mobile/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:vivia_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/login_google_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/register_lessee_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/register_lessor_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/register_lessee_google_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/register_lessor_google_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/set_location_permission_shown_usecase.dart';
import 'package:vivia_mobile/features/auth/domain/usecases/put_ubication_usecase.dart';
import 'package:vivia_mobile/features/auth/presentation/viewmodels/auth_viewmodel.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final prefs = await SharedPreferences.getInstance();
  final localDatasource = AuthLocalDatasourceImpl(prefs);

  // Referencia mutable que el interceptor usará para notificar sesión expirada.
  // El closure captura la variable por referencia — authViewModel se asigna
  // antes de runApp(), así que siempre está inicializado cuando se invoca.
  AuthViewModel? authViewModelRef;

  final authHttpClient = AuthHttpClient(
    http.Client(),
    localDatasource,
    () => authViewModelRef?.handleSessionExpired(),
  );

  final remoteDatasource = AuthRemoteDatasourceImpl(authHttpClient);

  final authRepository = AuthRepositoryImpl(
    remote: remoteDatasource,
    local: localDatasource,
  );

  final loginUseCase = LoginUseCase(authRepository);
  final loginGoogleUseCase = LoginGoogleUseCase(authRepository);
  final registerLesseeUseCase = RegisterLesseeUseCase(authRepository);
  final registerLessorUseCase = RegisterLessorUseCase(authRepository);
  final registerLesseeGoogleUseCase = RegisterLesseeGoogleUseCase(authRepository);
  final registerLessorGoogleUseCase = RegisterLessorGoogleUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final setLocationPermissionShownUseCase = SetLocationPermissionShownUseCase(authRepository);
  final putUbicationUseCase = PutUbicationUseCase(authRepository);

  final authViewModel = AuthViewModel(
    loginUseCase: loginUseCase,
    loginGoogleUseCase: loginGoogleUseCase,
    registerLesseeUseCase: registerLesseeUseCase,
    registerLessorUseCase: registerLessorUseCase,
    registerLesseeGoogleUseCase: registerLesseeGoogleUseCase,
    registerLessorGoogleUseCase: registerLessorGoogleUseCase,
    logoutUseCase: logoutUseCase,
    setLocationPermissionShownUseCase: setLocationPermissionShownUseCase,
    putUbicationUseCase: putUbicationUseCase,
    authRepository: authRepository,
  );
  authViewModelRef = authViewModel;

  // Datos de sesión guardados
  final isLoggedIn = authRepository.isLoggedIn;
  final savedUserName = authRepository.savedUserName;
  final savedRole = authRepository.savedRole;
  final savedAvatarUrl = authRepository.savedAvatarUrl;

  final app = MyApp(
    isLoggedIn: isLoggedIn,
    savedUserName: savedUserName,
    savedRole: savedRole,
    savedAvatarUrl: savedAvatarUrl,
  );

  runApp(
    ChangeNotifierProvider.value(
      value: authViewModel,
      child: kIsWeb
          ? DevicePreview(enabled: true, builder: (_) => app)
          : app,
    ),
  );
}

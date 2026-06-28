import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:vivia_mobile/features/home/data/datasources/remote/property_remote_datasource.dart';
import 'package:vivia_mobile/features/home/data/repositories/property_repository_impl.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_properties_me_likes_usecase.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_properties_me_usecase.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_property_by_id_usecase.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_property_media_usecase.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_property_suggestions_usecase.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_property_types_usecase.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/property_viewmodel.dart';
import 'package:vivia_mobile/features/lessor/data/datasources/remote/lessor_remote_datasource.dart';
import 'package:vivia_mobile/features/lessor/data/repositories/lessor_repository_impl.dart';
import 'package:vivia_mobile/features/lessor/domain/usecases/get_amenities_usecase.dart';
import 'package:vivia_mobile/features/lessor/domain/usecases/get_neighborhoods_usecase.dart';
import 'package:vivia_mobile/features/lessor/domain/usecases/publish_property_draft_usecase.dart';
import 'package:vivia_mobile/features/lessor/presentation/viewmodels/property_draft_viewmodel.dart';
import 'package:vivia_mobile/features/user/data/datasources/remote/user_remote_datasource.dart';
import 'package:vivia_mobile/features/user/data/repositories/user_repository_impl.dart';
import 'package:vivia_mobile/features/user/domain/usecases/get_me_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/register_fcm_token_usecase.dart';
import 'package:vivia_mobile/features/user/presentation/viewmodels/user_viewmodel.dart';
import 'package:vivia_mobile/firebase_options.dart';

import 'app.dart';

const _channelId = 'vivia_notifications';
const _channelName = 'Vivia Notificaciones';

final FlutterLocalNotificationsPlugin _localNotifications =
FlutterLocalNotificationsPlugin();

// Handler para mensajes en background/terminated — debe ser top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> _initLocalNotifications() async {
  const androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await _localNotifications.initialize(initSettings);

  // Canal requerido para Android 8+
  const channel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    importance: Importance.high,
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

void _listenForegroundMessages() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _initLocalNotifications();
  _listenForegroundMessages();

  // Solicitar permiso de notificaciones (crítico en Android 13+ / iOS)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

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

  final userRemoteDatasource = UserRemoteDatasourceImpl(authHttpClient);
  final userRepository = UserRepositoryImpl(remote: userRemoteDatasource);
  final registerFcmTokenUseCase = RegisterFcmTokenUseCase(userRepository);
  final getMeUseCase = GetMeUseCase(userRepository);

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
    registerFcmTokenUseCase: registerFcmTokenUseCase,
  );
  authViewModelRef = authViewModel;

  final userViewModel = UserViewModel(getMeUseCase: getMeUseCase);

  final propertyRemoteDatasource = PropertyRemoteDatasourceImpl(authHttpClient);
  final propertyRepository = PropertyRepositoryImpl(remote: propertyRemoteDatasource);
  final propertyViewModel = PropertyViewModel(
    getPropertyTypesUseCase: GetPropertyTypesUseCase(propertyRepository),
    getPropertiesMeUseCase: GetPropertiesMeUseCase(propertyRepository),
    getPropertiesMeLikesUseCase: GetPropertiesMeLikesUseCase(propertyRepository),
    getPropertySuggestionsUseCase: GetPropertySuggestionsUseCase(propertyRepository),
    authRepository: authRepository,
  );


  // Use case del detalle: la VM de detalle se construye por pantalla (per-propiedad),
  // así que se expone el use case y cada PropertyDetailPage crea su propia VM.
  final getPropertyByIdUseCase = GetPropertyByIdUseCase(propertyRepository);
  final getPropertyMediaUseCase = GetPropertyMediaUseCase(propertyRepository);

  final lessorRemoteDatasource =
      LessorRemoteDatasourceImpl(authHttpClient, http.Client());
  final lessorRepository =
      LessorRepositoryImpl(remote: lessorRemoteDatasource);
  final propertyDraftViewModel = PropertyDraftViewModel(
    getNeighborhoodsUseCase: GetNeighborhoodsUseCase(lessorRepository),
    getAmenitiesUseCase: GetAmenitiesUseCase(lessorRepository),
    publishPropertyDraftUseCase: PublishPropertyDraftUseCase(lessorRepository),
  );


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
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authViewModel),
        ChangeNotifierProvider.value(value: userViewModel),
        ChangeNotifierProvider.value(value: propertyViewModel),
        Provider<GetPropertyByIdUseCase>.value(value: getPropertyByIdUseCase),
        Provider<GetPropertyMediaUseCase>.value(value: getPropertyMediaUseCase),
        ChangeNotifierProvider.value(value: propertyDraftViewModel),
      ],
      child: kIsWeb
          ? DevicePreview(enabled: true, builder: (_) => app)
          : app,
    ),
  );
}
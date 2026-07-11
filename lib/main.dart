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
import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';
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
import 'package:vivia_mobile/core/database/app_database.dart';
import 'package:vivia_mobile/core/utils/jwt_utils.dart';
import 'package:vivia_mobile/shared/chat/data/datasources/local/chat_mock_datasource.dart';
import 'package:vivia_mobile/shared/chat/data/repositories/chat_repository_impl.dart';
import 'package:vivia_mobile/shared/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:vivia_mobile/shared/chat/domain/usecases/get_messages_usecase.dart';
import 'package:vivia_mobile/shared/notifications/data/datasources/local/notification_local_datasource.dart';
import 'package:vivia_mobile/shared/notifications/data/mappers/notification_message_mapper.dart';
import 'package:vivia_mobile/shared/notifications/data/models/notification_entity.dart';
import 'package:vivia_mobile/shared/notifications/data/repositories/notification_repository_impl.dart';
import 'package:vivia_mobile/shared/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:vivia_mobile/shared/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:vivia_mobile/shared/notifications/domain/usecases/mark_notifications_read_usecase.dart';
import 'package:vivia_mobile/shared/notifications/domain/usecases/save_notification_usecase.dart';
import 'package:vivia_mobile/shared/property/data/datasources/remote/property_remote_datasource.dart';
import 'package:vivia_mobile/features/lessee/reports/data/datasources/remote/report_remote_datasource.dart';
import 'package:vivia_mobile/shared/property/data/repositories/property_repository_impl.dart';
import 'package:vivia_mobile/features/lessee/reports/data/repositories/report_repository_impl.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_properties_me_likes_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_properties_me_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_properties_near_me_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_property_by_id_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_property_media_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_property_suggestions_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/get_property_types_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/add_property_media_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/change_main_image_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/delete_property_media_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/delete_property_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/update_property_usecase.dart';
import 'package:vivia_mobile/features/lessee/reports/domain/usecases/get_report_reasons_usecase.dart';
import 'package:vivia_mobile/features/lessee/reports/domain/usecases/submit_report_usecase.dart';
import 'package:vivia_mobile/shared/property/domain/usecases/toggle_like_usecase.dart';
import 'package:vivia_mobile/features/home/presentation/viewmodels/property_viewmodel.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/datasources/remote/lessor_remote_datasource.dart';
import 'package:vivia_mobile/features/lessor/verification/data/datasources/remote/lessor_verification_remote_datasource.dart';
import 'package:vivia_mobile/features/lessor/publishing/data/repositories/lessor_repository_impl.dart';
import 'package:vivia_mobile/features/lessor/verification/data/repositories/lessor_verification_repository_impl.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/usecases/get_verification_status_usecase.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/usecases/request_verification_upload_urls_usecase.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/usecases/reset_verification_usecase.dart';
import 'package:vivia_mobile/features/lessor/verification/domain/usecases/upload_verification_document_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/get_amenities_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/get_neighborhoods_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/publish_property_draft_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/domain/usecases/watch_draft_status_usecase.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/viewmodels/property_draft_viewmodel.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/viewmodels/verification_viewmodel.dart';
import 'package:vivia_mobile/features/user/data/datasources/remote/user_remote_datasource.dart';
import 'package:vivia_mobile/features/user/data/repositories/user_repository_impl.dart';
import 'package:vivia_mobile/features/user/domain/usecases/get_me_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/get_profile_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_email_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_name_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_password_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_phone_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/update_profile_photo_usecase.dart';
import 'package:vivia_mobile/features/user/domain/usecases/register_fcm_token_usecase.dart';
import 'package:vivia_mobile/features/maps/data/datasources/remote/maps_remote_datasource.dart';
import 'package:vivia_mobile/features/maps/data/repositories/maps_repository_impl.dart';
import 'package:vivia_mobile/features/maps/domain/usecases/geocode_address_usecase.dart';
import 'package:vivia_mobile/features/maps/domain/usecases/reverse_geocode_usecase.dart';
import 'package:vivia_mobile/features/user/presentation/viewmodels/user_viewmodel.dart';
import 'package:vivia_mobile/firebase_options.dart';

import 'app.dart';

const _channelId = 'vivia_notifications';
const _channelName = 'Vivia Notificaciones';

final FlutterLocalNotificationsPlugin _localNotifications =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _persistIncoming(message);
}

String? _userIdFromToken(String token) {
  final claims = JwtUtils.decodePayload(token);
  return claims['sub']?.toString() ??
      claims['userId']?.toString() ??
      claims['id']?.toString();
}

Future<void> _persistIncoming(RemoteMessage message) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  if (token == null) return;
  final userId = _userIdFromToken(token);
  if (userId == null) return;
  final model = NotificationMessageMapper.toModel(message);
  final datasource = NotificationLocalDatasourceImpl(AppDatabase.instance);
  await datasource.insert(NotificationEntity.fromModel(model, userId));
}

Future<void> _initLocalNotifications() async {
  const androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await _localNotifications.initialize(initSettings);

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

void _listenForegroundMessages(void Function(RemoteMessage) onCapture) {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    onCapture(message);

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

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final prefs = await SharedPreferences.getInstance();
  final localDatasource = AuthLocalDatasourceImpl(prefs);

  AuthViewModel? authViewModelRef;
  PropertyViewModel? propertyViewModelRef;

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
  final registerLesseeGoogleUseCase =
  RegisterLesseeGoogleUseCase(authRepository);
  final registerLessorGoogleUseCase =
  RegisterLessorGoogleUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final setLocationPermissionShownUseCase =
  SetLocationPermissionShownUseCase(authRepository);
  final putUbicationUseCase = PutUbicationUseCase(authRepository);

  final userRemoteDatasource =
      UserRemoteDatasourceImpl(authHttpClient, http.Client());
  final userRepository = UserRepositoryImpl(remote: userRemoteDatasource);
  final registerFcmTokenUseCase = RegisterFcmTokenUseCase(userRepository);
  final getMeUseCase = GetMeUseCase(userRepository);
  final getProfileUseCase = GetProfileUseCase(userRepository);
  final updateNameUseCase = UpdateNameUseCase(userRepository);
  final updateEmailUseCase = UpdateEmailUseCase(userRepository);
  final updatePhoneUseCase = UpdatePhoneUseCase(userRepository);
  final updatePasswordUseCase = UpdatePasswordUseCase(userRepository);
  final updateProfilePhotoUseCase = UpdateProfilePhotoUseCase(userRepository);

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
    onSessionCleared: () => propertyViewModelRef?.reset(),
  );
  authViewModelRef = authViewModel;

  final userViewModel = UserViewModel(getMeUseCase: getMeUseCase);

  final propertyRemoteDatasource =
  PropertyRemoteDatasourceImpl(authHttpClient, http.Client());
  final propertyRepository =
  PropertyRepositoryImpl(remote: propertyRemoteDatasource);
  final propertyViewModel = PropertyViewModel(
    getPropertyTypesUseCase: GetPropertyTypesUseCase(propertyRepository),
    getPropertiesMeUseCase: GetPropertiesMeUseCase(propertyRepository),
    getPropertiesMeLikesUseCase:
    GetPropertiesMeLikesUseCase(propertyRepository),
    getPropertySuggestionsUseCase:
    GetPropertySuggestionsUseCase(propertyRepository),
    getPropertiesNearMeUseCase:
    GetPropertiesNearMeUseCase(propertyRepository),
    authRepository: authRepository,
  );
  propertyViewModelRef = propertyViewModel;

  final getPropertyByIdUseCase = GetPropertyByIdUseCase(propertyRepository);
  final getPropertyMediaUseCase = GetPropertyMediaUseCase(propertyRepository);
  final toggleLikeUseCase = ToggleLikeUseCase(propertyRepository);
  final deletePropertyUseCase = DeletePropertyUseCase(propertyRepository);
  final updatePropertyUseCase = UpdatePropertyUseCase(propertyRepository);
  final addPropertyMediaUseCase = AddPropertyMediaUseCase(propertyRepository);
  final changeMainImageUseCase = ChangeMainImageUseCase(propertyRepository);
  final deletePropertyMediaUseCase =
  DeletePropertyMediaUseCase(propertyRepository);

  // Servicio de mapas propio (sin auth): cliente plano para no enviar el JWT.
  final mapsRemoteDatasource = MapsRemoteDatasourceImpl(http.Client());
  final mapsRepository = MapsRepositoryImpl(remote: mapsRemoteDatasource);
  final geocodeAddressUseCase = GeocodeAddressUseCase(mapsRepository);
  final reverseGeocodeUseCase = ReverseGeocodeUseCase(mapsRepository);

  final lessorRemoteDatasource =
  LessorRemoteDatasourceImpl(authHttpClient, http.Client());
  final lessorRepository =
  LessorRepositoryImpl(remote: lessorRemoteDatasource);
  final propertyDraftViewModel = PropertyDraftViewModel(
    getNeighborhoodsUseCase: GetNeighborhoodsUseCase(lessorRepository),
    getAmenitiesUseCase: GetAmenitiesUseCase(lessorRepository),
    publishPropertyDraftUseCase: PublishPropertyDraftUseCase(lessorRepository),
    watchDraftStatusUseCase: WatchDraftStatusUseCase(lessorRepository),
    geocodeAddressUseCase: geocodeAddressUseCase,
    reverseGeocodeUseCase: reverseGeocodeUseCase,
    updatePropertyUseCase: updatePropertyUseCase,
  );

  final lessorVerificationRemoteDatasource =
  LessorVerificationRemoteDatasourceImpl(authHttpClient, http.Client());
  final lessorVerificationRepository = LessorVerificationRepositoryImpl(
    remote: lessorVerificationRemoteDatasource,
  );
  final verificationViewModel = VerificationViewModel(
    getVerificationStatusUseCase:
    GetVerificationStatusUseCase(lessorVerificationRepository),
    requestUploadUrlsUseCase:
    RequestVerificationUploadUrlsUseCase(lessorVerificationRepository),
    resetVerificationUseCase:
    ResetVerificationUseCase(lessorVerificationRepository),
    uploadDocumentUseCase:
    UploadVerificationDocumentUseCase(lessorVerificationRepository),
  );

  final reportRemoteDatasource = ReportRemoteDatasourceImpl(authHttpClient);
  final reportRepository =
  ReportRepositoryImpl(remote: reportRemoteDatasource);
  final submitReportUseCase = SubmitReportUseCase(reportRepository);
  final getReportReasonsUseCase = GetReportReasonsUseCase(reportRepository);

  final notificationLocalDatasource =
  NotificationLocalDatasourceImpl(AppDatabase.instance);
  final notificationRepository = NotificationRepositoryImpl(
    local: notificationLocalDatasource,
    getUserId: () => authRepository.savedUserId,
  );
  final getNotificationsUseCase =
  GetNotificationsUseCase(notificationRepository);
  final saveNotificationUseCase =
  SaveNotificationUseCase(notificationRepository);
  final markNotificationsReadUseCase =
  MarkNotificationsReadUseCase(notificationRepository);
  final getUnreadCountUseCase =
  GetUnreadCountUseCase(notificationRepository);

  final chatRepository = ChatRepositoryImpl(local: ChatMockDatasourceImpl());
  final getConversationsUseCase = GetConversationsUseCase(chatRepository);
  final getMessagesUseCase = GetMessagesUseCase(chatRepository);

  _listenForegroundMessages(
    (message) => saveNotificationUseCase.execute(
      NotificationMessageMapper.toModel(message),
    ),
  );

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
        Provider<ToggleLikeUseCase>.value(value: toggleLikeUseCase),
        Provider<DeletePropertyUseCase>.value(value: deletePropertyUseCase),
        Provider<AddPropertyMediaUseCase>.value(
            value: addPropertyMediaUseCase),
        Provider<ChangeMainImageUseCase>.value(value: changeMainImageUseCase),
        Provider<DeletePropertyMediaUseCase>.value(
            value: deletePropertyMediaUseCase),
        Provider<GetProfileUseCase>.value(value: getProfileUseCase),
        Provider<UpdateNameUseCase>.value(value: updateNameUseCase),
        Provider<UpdateEmailUseCase>.value(value: updateEmailUseCase),
        Provider<UpdatePhoneUseCase>.value(value: updatePhoneUseCase),
        Provider<UpdatePasswordUseCase>.value(value: updatePasswordUseCase),
        Provider<UpdateProfilePhotoUseCase>.value(
            value: updateProfilePhotoUseCase),
        Provider<PutUbicationUseCase>.value(value: putUbicationUseCase),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<SubmitReportUseCase>.value(value: submitReportUseCase),
        ChangeNotifierProvider.value(value: propertyDraftViewModel),
        ChangeNotifierProvider.value(value: verificationViewModel),
        Provider<GetReportReasonsUseCase>.value(value: getReportReasonsUseCase),
        Provider<GeocodeAddressUseCase>.value(value: geocodeAddressUseCase),
        Provider<GetNotificationsUseCase>.value(
            value: getNotificationsUseCase),
        Provider<MarkNotificationsReadUseCase>.value(
            value: markNotificationsReadUseCase),
        Provider<GetUnreadCountUseCase>.value(value: getUnreadCountUseCase),
        Provider<GetConversationsUseCase>.value(
            value: getConversationsUseCase),
        Provider<GetMessagesUseCase>.value(value: getMessagesUseCase),
      ],
      child: kIsWeb
          ? DevicePreview(enabled: true, builder: (_) => app)
          : app,
    ),
  );
}
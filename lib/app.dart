import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/core/deeplink/premium_deep_link.dart';
import 'package:vivia_mobile/core/deeplink/property_deep_link.dart';
import 'package:vivia_mobile/features/premium/presentation/viewmodels/premium_viewmodel.dart';
import 'package:vivia_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:vivia_mobile/features/home/presentation/pages/property_deep_link_page.dart';
import 'package:vivia_mobile/shared/theme/theme.dart';
import 'package:vivia_mobile/shared/theme/util.dart';

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final String? savedUserName;
  final String? savedRole;
  final String? savedAvatarUrl;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.savedUserName,
    this.savedRole,
    this.savedAvatarUrl,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  // Evita procesar dos veces el mismo enlace (el stream puede reemitir el
  // enlace inicial en algunas plataformas, y protege de toques repetidos).
  String? _lastHandledId;
  DateTime? _lastHandledAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // App ya abierta o en background: navega en cuanto llega el enlace.
    _linkSub = _appLinks.uriLinkStream.listen(_handleUri);

    // Arranque en frío: el splash hace su propia navegación (~2.9s). Esperamos
    // a que termine para empujar el detalle encima del home, no debajo.
    final initial = await _appLinks.getInitialLink();
    if (initial == null) return;
    Future.delayed(
      const Duration(seconds: 3),
      () => _handleUri(initial),
    );
  }

  void _handleUri(Uri uri) {
    final premium = PremiumDeepLink.parse(uri);
    if (premium != null) {
      _handlePremiumReturn(premium);
      return;
    }
    _openProperty(uri);
  }

  void _handlePremiumReturn(PremiumDeepLinkResult result) {
    if (result != PremiumDeepLinkResult.success) return;
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    Provider.of<PremiumViewModel>(ctx, listen: false).refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    Provider.of<PremiumViewModel>(ctx, listen: false).refresh();
  }

  void _openProperty(Uri uri) {
    final id = PropertyDeepLink.parsePropertyId(uri);
    if (id == null) return;

    final now = DateTime.now();
    if (id == _lastHandledId &&
        _lastHandledAt != null &&
        now.difference(_lastHandledAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastHandledId = id;
    _lastHandledAt = now;

    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => PropertyDeepLinkPage(propertyId: id),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");
    MaterialTheme materialTheme = MaterialTheme(textTheme);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Vivia',
      debugShowCheckedModeBanner: false,
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.light,
      home: SplashPage(
        isLoggedIn: widget.isLoggedIn,
        savedUserName: widget.savedUserName,
        savedRole: widget.savedRole,
        savedAvatarUrl: widget.savedAvatarUrl,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/presentation/pages/choose_option_page.dart';
import 'package:vivia_mobile/features/auth/presentation/pages/location_permissions_page.dart';
import 'package:vivia_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:vivia_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:vivia_mobile/features/home/presentation/pages/home_page.dart';
import 'package:vivia_mobile/shared/theme/theme.dart';
import 'package:vivia_mobile/shared/theme/util.dart';

class MyApp extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");
    MaterialTheme materialTheme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'Vivia',
      debugShowCheckedModeBanner: false,
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.light,
      home: SplashPage(
        isLoggedIn: isLoggedIn,
        savedUserName: savedUserName,
        savedRole: savedRole,
        savedAvatarUrl: savedAvatarUrl,
      ),
    );
  }
}
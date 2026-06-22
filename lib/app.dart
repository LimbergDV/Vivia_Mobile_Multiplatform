import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:vivia_mobile/shared/theme/theme.dart';
import 'package:vivia_mobile/shared/theme/util.dart';

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

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
      home: SplashPage(isLoggedIn: isLoggedIn),
    );
  }
}

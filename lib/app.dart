import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:vivia_mobile/shared/theme/theme.dart';
import 'package:vivia_mobile/shared/theme/util.dart';
import 'package:vivia_mobile/features/auth/presentation/pages/login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const RegisterPage(),
    );
  }
}
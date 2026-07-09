import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Loader del flujo de verificación: animación de edificios centrada.
class VerifyLoader extends StatelessWidget {
  final double size;

  const VerifyLoader({super.key, this.size = 220});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Lottie.asset(
          'assets/images/builings-loader.json',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

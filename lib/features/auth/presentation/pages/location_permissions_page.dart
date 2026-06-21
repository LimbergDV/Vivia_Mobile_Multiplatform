import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vivia_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:vivia_mobile/features/auth/presentation/pages/role_selector_page.dart';

class LocationPermissionsPage extends StatelessWidget {
  const LocationPermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.06),

              SizedBox(
                width: screenWidth * 0.75,   // 75% del ancho de pantalla
                height: screenHeight * 0.35, // 35% del alto de pantalla
                child: Lottie.asset(
                  'assets/images/locations_animated_icon.json',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              Text(
                'Por favor permite el acceso a tu ubicación',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              Text(
                'Vivía utiliza tu ubicación para encontrar puntos de interés cercanos a ti.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                      MaterialPageRoute(builder: (_) => const RoleSelectorPage()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Permitir Ubicación',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Saltar por ahora',
                    style: textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: colorScheme.onSurface,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
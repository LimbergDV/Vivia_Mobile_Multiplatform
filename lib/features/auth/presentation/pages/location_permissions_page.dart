import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:vivia_mobile/features/auth/domain/enums/user_role.dart';
import 'package:vivia_mobile/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:vivia_mobile/features/home/presentation/pages/home_page.dart';

class LocationPermissionsPage extends StatefulWidget {
  final String userName;
  final UserRole role;
  final String? avatarUrl;

  const LocationPermissionsPage({
    super.key,
    required this.userName,
    required this.role,
    this.avatarUrl,
  });

  @override
  State<LocationPermissionsPage> createState() =>
      _LocationPermissionsPageState();
}

class _LocationPermissionsPageState extends State<LocationPermissionsPage> {
  bool _isLoading = false;

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomePage(
          userName: widget.userName,
          role: widget.role,
          avatarUrl: widget.avatarUrl,
        ),
      ),
      (_) => false,
    );
  }

  Future<void> _onAllowPressed() async {
    setState(() => _isLoading = true);

    try {
      final permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 10),
            ),
          );
          if (mounted) {
            context.read<AuthViewModel>().putUbicationFireAndForget(
                  position.latitude,
                  position.longitude,
                );
          }
        } catch (_) {
          // Optimistic UI: si falla obtener posición, igual continuamos
        }
      }
    } catch (_) {
      // Optimistic UI: si falla el permiso del OS, igual continuamos
    }

    if (mounted) {
      await context.read<AuthViewModel>().markLocationPermissionShown();
      _navigateToHome();
    }
  }

  Future<void> _onSkipPressed() async {
    await context.read<AuthViewModel>().markLocationPermissionShown();
    _navigateToHome();
  }

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
                width: screenWidth * 0.75,
                height: screenHeight * 0.35,
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
                  onPressed: _isLoading ? null : _onAllowPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor:
                        colorScheme.primary.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Text(
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
                onTap: _isLoading ? null : _onSkipPressed,
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

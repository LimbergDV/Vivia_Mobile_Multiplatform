import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/auth_background_blobs.dart';
import 'package:vivia_mobile/features/home/presentation/pages/verify_intro_page.dart';
import 'package:vivia_mobile/features/home/presentation/pages/verify_results_page.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/verify/verify_step_indicator.dart';

class VerifyFacePage extends StatelessWidget {
  const VerifyFacePage({super.key});

  void _onTakePhoto(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const VerifyResultsPage()),
    );
  }

  void _onCancel(BuildContext context) {
    Navigator.of(context).popUntil(
          (route) => route.settings.name == VerifyIntroPage.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Verificar Identidad',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: isLandscape ? _buildLandscape(context) : _buildPortrait(context),
    );
  }

  Widget _buildPortrait(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Text(
            'Toma una foto a tu identificación',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: VerifyStepIndicator(
            stepNumber: 3,
            title:
            'Toma una foto de tu rostro para comprobar que eres el mismo de la identificación',
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Center(
            child: Lottie.asset(
              'assets/images/scan-face.json',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => _onTakePhoto(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0095FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Tomar foto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () => _onCancel(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        RepaintBoundary(
          child: SizedBox(
            height: 160,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.bottomCenter,
                maxHeight: 260,
                child: const AuthBackgroundBlobs(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscape(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Toma una foto a tu identificación',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const VerifyStepIndicator(
                  stepNumber: 3,
                  title:
                  'Toma una foto de tu rostro para comprobar que eres el mismo de la identificación',
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(
            width: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 24, 16),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Lottie.asset(
                      'assets/images/scan-face.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: FilledButton(
                          onPressed: () => _onTakePhoto(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0095FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Tomar foto',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    TextButton(
                      onPressed: () => _onCancel(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
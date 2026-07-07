import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/auth_background_blobs.dart';
import 'package:vivia_mobile/features/home/presentation/pages/verify_face_page.dart';
import 'package:vivia_mobile/features/home/presentation/pages/verify_intro_page.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/verify/verify_id_frame.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/verify/verify_step_indicator.dart';

class VerifyBackIdPage extends StatelessWidget {
  const VerifyBackIdPage({super.key});

  void _onTakePhoto(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VerifyFacePage()),
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
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: VerifyStepIndicator(
            stepNumber: 2,
            title: 'Toma una foto a la segunda cara de la credencial',
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: VerifyIdFrame(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    'assets/images/INE-back.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
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
        const SizedBox(height: 8),
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
        const RepaintBoundary(child: AuthBackgroundBlobs()),
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
                  stepNumber: 2,
                  title: 'Toma una foto a la segunda cara de la credencial',
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
                    child: VerifyIdFrame(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.asset(
                          'assets/images/INE-back.png',
                          fit: BoxFit.cover,
                        ),
                      ),
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
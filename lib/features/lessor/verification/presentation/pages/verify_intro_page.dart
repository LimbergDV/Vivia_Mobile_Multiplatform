import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/auth_background_blobs.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/pages/verify_front_id_page.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/widgets/verify_step_indicator.dart';
import 'package:vivia_mobile/features/lessor/verification/presentation/viewmodels/verification_viewmodel.dart';

class VerifyIntroPage extends StatelessWidget {
  static const routeName = 'verify/intro';

  const VerifyIntroPage({super.key});

  static const _privacyNote =
      'Vivia solicita esta información para salvaguardar a nuestros usuarios '
      'de extorciones y estafas. Gracias por colaborar con nosotros.';

  void _goNext(BuildContext context) {
    context.read<VerificationViewModel>().clearStagedDocuments();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VerifyFrontIdPage()),
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

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sobre el proceso de verificación',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),
                const VerifyStepIndicator(
                  stepNumber: 1,
                  title: 'Búsca una identificación oficial',
                  subtitle:
                  'Puede ser:\n• Credencial para votar INE\n• Licencia de conducir',
                ),
                const SizedBox(height: 28),
                const VerifyStepIndicator(
                  stepNumber: 2,
                  title: 'Toma una fotografía',
                  subtitle:
                  'Deberás tomarle una fotografía a cada lado al documento de identificación oficial.',
                ),
                const SizedBox(height: 28),
                const VerifyStepIndicator(
                  stepNumber: 3,
                  title: 'Esperar',
                  subtitle:
                  'El equipo de Vivia se encargará del resto. Te notificaremos cuando seas verificado.',
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => _goNext(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0095FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Empezar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  _privacyNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: RepaintBoundary(child: AuthBackgroundBlobs()),
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
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sobre el proceso de verificación',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const VerifyStepIndicator(
                  stepNumber: 1,
                  title: 'Búsca una identificación oficial',
                  subtitle:
                  'Puede ser:\n• Credencial para votar INE\n• Licencia de conducir',
                ),
                const SizedBox(height: 20),
                const VerifyStepIndicator(
                  stepNumber: 2,
                  title: 'Toma una fotografía',
                  subtitle:
                  'Deberás tomarle una fotografía a cada lado al documento de identificación oficial.',
                ),
                const SizedBox(height: 20),
                const VerifyStepIndicator(
                  stepNumber: 3,
                  title: 'Esperar',
                  subtitle:
                  'El equipo de Vivia se encargará del resto. Te notificaremos cuando seas verificado.',
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 24, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () => _goNext(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0095FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Empezar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  _privacyNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
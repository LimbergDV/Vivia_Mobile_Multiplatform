import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vivia_mobile/features/auth/presentation/widgets/auth_background_blobs.dart';
import 'package:vivia_mobile/features/home/presentation/pages/verify_intro_page.dart';
import 'package:vivia_mobile/features/home/presentation/widgets/verify/verify_step_indicator.dart';

class VerifyResultsPage extends StatelessWidget {
  const VerifyResultsPage({super.key});

  static const _privacyNote =
      'Vivia solicita esta información para salvaguardar a nuestros usuarios '
      'de extorciones y estafas. Gracias por colaborar con nosotros.';

  void _onBack(BuildContext context) {
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
          onPressed: () => _onBack(context),
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
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resultados',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 28),
                const VerifyStepIndicator(
                  title: 'Tus datos fueron enviados correctamente',
                  subtitle:
                  'El equipo de Vivia esta revisando tus documentos, nosotros te notificaremos cuando los resultados estén disponibles.',
                ),
                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      'assets/images/clock.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                const Text(
                  _privacyNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ),
        const RepaintBoundary(child: AuthBackgroundBlobs()),
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
                  'Resultados',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                const VerifyStepIndicator(
                  title: 'Tus datos fueron enviados correctamente',
                  subtitle:
                  'El equipo de Vivia esta revisando tus documentos, nosotros te notificaremos cuando los resultados estén disponibles.',
                ),
                const SizedBox(height: 24),
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
        const VerticalDivider(
            width: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),
        Expanded(
          flex: 4,
          child: Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Lottie.asset(
                'assets/images/clock.json',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
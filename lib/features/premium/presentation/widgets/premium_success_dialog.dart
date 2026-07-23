import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class PremiumSuccessDialog {
  const PremiumSuccessDialog._();

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PremiumSuccessView(),
    );
  }
}

class _PremiumSuccessView extends StatefulWidget {
  const _PremiumSuccessView();

  @override
  State<_PremiumSuccessView> createState() => _PremiumSuccessViewState();
}

class _PremiumSuccessViewState extends State<_PremiumSuccessView> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2))
      ..play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        const _SuccessCard(),
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 18,
          maxBlastForce: 14,
          minBlastForce: 6,
          gravity: 0.25,
          emissionFrequency: 0.04,
          colors: const [
            Color(0xFF26C6DA),
            Color(0xFF62E8EC),
            Color(0xFFFFC107),
            Colors.white,
          ],
        ),
      ],
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      icon: const Icon(Icons.workspace_premium_rounded,
          color: Color(0xFF26C6DA), size: 52),
      title: const Text('¡Felicidades!', textAlign: TextAlign.center),
      content: Text(
        'Ya eres Premium. Disfruta de propiedades y chats ilimitados, más la '
        'generación de contenido con IA.',
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('¡Genial!'),
        ),
      ],
    );
  }
}

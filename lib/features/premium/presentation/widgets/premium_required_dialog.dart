import 'package:flutter/material.dart';

import 'package:vivia_mobile/features/premium/presentation/pages/paywall_page.dart';

class PremiumRequiredDialog {
  const PremiumRequiredDialog._();

  static Future<void> show(
    BuildContext context, {
    String message =
        'Esta función es exclusiva de Vivía Premium. Suscríbete para desbloquearla.',
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => _PremiumRequiredView(message: message),
    );
  }
}

class _PremiumRequiredView extends StatelessWidget {
  final String message;
  const _PremiumRequiredView({required this.message});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      icon: const Icon(Icons.workspace_premium_rounded,
          color: Color(0xFF26C6DA), size: 40),
      title: const Text('Función Premium'),
      content: Text(message, style: textTheme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ahora no'),
        ),
        FilledButton(
          onPressed: () => _goToPaywall(context),
          child: const Text('Ver Premium'),
        ),
      ],
    );
  }

  void _goToPaywall(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaywallPage()),
    );
  }
}

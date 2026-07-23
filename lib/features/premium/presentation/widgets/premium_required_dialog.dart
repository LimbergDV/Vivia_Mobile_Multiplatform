import 'package:flutter/material.dart';

import 'package:vivia_mobile/features/premium/presentation/pages/paywall_page.dart';

class PremiumRequiredDialog {
  const PremiumRequiredDialog._();

  /// Devuelve `true` si el usuario terminó suscribiéndose (quedó Premium),
  /// de modo que el llamador pueda retomar la acción que abrió el diálogo.
  static Future<bool> show(
    BuildContext context, {
    String message =
        'Esta función es exclusiva de Vivía Premium. Suscríbete para desbloquearla.',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _PremiumRequiredView(message: message),
    );
    return result ?? false;
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
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Ahora no'),
        ),
        FilledButton(
          onPressed: () => _goToPaywall(context),
          child: const Text('Ver Premium'),
        ),
      ],
    );
  }

  Future<void> _goToPaywall(BuildContext context) async {
    final becamePremium = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PaywallPage()),
    );
    if (!context.mounted) return;
    Navigator.of(context).pop(becamePremium == true);
  }
}

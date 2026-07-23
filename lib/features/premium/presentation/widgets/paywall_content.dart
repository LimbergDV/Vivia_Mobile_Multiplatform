import 'package:flutter/material.dart';

import 'package:vivia_mobile/features/premium/domain/enums/payment_method.dart';

class PaywallContent extends StatelessWidget {
  final bool isPremium;
  final DateTime? premiumUntil;
  final PaymentMethod? pendingMethod;
  final bool creating;
  final void Function(PaymentMethod method) onSelectMethod;

  const PaywallContent({
    super.key,
    required this.isPremium,
    required this.premiumUntil,
    required this.pendingMethod,
    required this.creating,
    required this.onSelectMethod,
  });

  static const _benefits = [
    'Publica propiedades ilimitadas',
    'Responde chats sin límite',
    'Genera título y descripción con IA',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const _PremiumHeader(),
        const SizedBox(height: 24),
        ..._benefits.map((b) => _BenefitRow(text: b)),
        const SizedBox(height: 20),
        Text('\$250 MXN / mes',
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Cada pago suma 30 días de Premium.',
            textAlign: TextAlign.center, style: textTheme.bodySmall),
        const SizedBox(height: 28),
        if (isPremium)
          _ActivePremium(premiumUntil: premiumUntil)
        else
          _MethodButtons(
            pendingMethod: pendingMethod,
            creating: creating,
            onSelectMethod: onSelectMethod,
          ),
      ],
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        const Icon(Icons.workspace_premium_rounded,
            size: 72, color: Color(0xFF26C6DA)),
        const SizedBox(height: 12),
        Text('Vivía Premium',
            style: textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF26C6DA), size: 22),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _ActivePremium extends StatelessWidget {
  final DateTime? premiumUntil;
  const _ActivePremium({required this.premiumUntil});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final until = premiumUntil;
    return Column(
      children: [
        Text('Eres Premium ✓',
            style: textTheme.titleLarge?.copyWith(
                color: const Color(0xFF26C6DA), fontWeight: FontWeight.w700)),
        if (until != null) ...[
          const SizedBox(height: 6),
          Text(
            'Válido hasta el ${until.day}/${until.month}/${until.year}',
            style: textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

class _MethodButtons extends StatelessWidget {
  final PaymentMethod? pendingMethod;
  final bool creating;
  final void Function(PaymentMethod method) onSelectMethod;

  const _MethodButtons({
    required this.pendingMethod,
    required this.creating,
    required this.onSelectMethod,
  });

  static const _icons = {
    PaymentMethod.card: Icons.credit_card_rounded,
    PaymentMethod.oxxo: Icons.store_rounded,
    PaymentMethod.spei: Icons.account_balance_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: PaymentMethod.values.map(_button).toList(),
    );
  }

  Widget _button(PaymentMethod method) {
    final busy = creating && pendingMethod == method;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: FilledButton.icon(
        onPressed: creating ? null : () => onSelectMethod(method),
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(_icons[method]),
        label: Text(method.label),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
        ),
      ),
    );
  }
}

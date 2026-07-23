import 'package:flutter/material.dart';

import 'package:vivia_mobile/features/premium/domain/models/payment_history_item.dart';
import 'package:vivia_mobile/features/premium/presentation/helpers/payment_display.dart';
import 'package:vivia_mobile/features/premium/presentation/widgets/payment_history_tile.dart';

class PaymentHistoryView extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<PaymentHistoryItem> items;
  final bool isPremium;
  final DateTime? premiumUntil;
  final VoidCallback onRetry;

  const PaymentHistoryView({
    super.key,
    required this.loading,
    required this.error,
    required this.items,
    required this.isPremium,
    required this.premiumUntil,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _SubscriptionHeader(isPremium: isPremium, premiumUntil: premiumUntil),
          const SizedBox(height: 20),
          ..._body(context),
        ],
      ),
    );
  }

  List<Widget> _body(BuildContext context) {
    if (loading) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (error != null) return [_Message(text: error!)];
    if (items.isEmpty) {
      return const [_Message(text: 'Aún no tienes pagos registrados.')];
    }
    return items.map((i) => PaymentHistoryTile(item: i)).toList();
  }
}

class _SubscriptionHeader extends StatelessWidget {
  final bool isPremium;
  final DateTime? premiumUntil;
  const _SubscriptionHeader({required this.isPremium, required this.premiumUntil});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? const [Color(0xFF62E8EC), Color(0xFF26C6DA)]
              : const [Color(0xFF90A4AE), Color(0xFF607D8B)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(child: _headerText(textTheme)),
        ],
      ),
    );
  }

  Widget _headerText(TextTheme textTheme) {
    final until = premiumUntil;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPremium ? 'Premium activo' : 'Sin suscripción activa',
          style: textTheme.titleMedium
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          isPremium && until != null
              ? 'Vigente hasta el ${PaymentDisplay.date(until)}'
              : 'Suscríbete para desbloquear todo Vivía',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.92)),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Text(text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

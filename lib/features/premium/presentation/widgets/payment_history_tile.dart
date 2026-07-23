import 'package:flutter/material.dart';

import 'package:vivia_mobile/features/premium/domain/models/payment_history_item.dart';
import 'package:vivia_mobile/features/premium/presentation/helpers/payment_display.dart';

class PaymentHistoryTile extends StatelessWidget {
  final PaymentHistoryItem item;
  const PaymentHistoryTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: _details(textTheme)),
            _StatusChip(status: item.status),
          ],
        ),
      ),
    );
  }

  Widget _details(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.method.label,
            style: textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('${PaymentDisplay.amount(item.amount)} · '
            '${PaymentDisplay.date(item.createdAt)}',
            style: textTheme.bodySmall),
        if (item.reference != null && item.reference!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Ref: ${item.reference}', style: textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final PaymentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = PaymentDisplay.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        PaymentDisplay.statusLabel(status),
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

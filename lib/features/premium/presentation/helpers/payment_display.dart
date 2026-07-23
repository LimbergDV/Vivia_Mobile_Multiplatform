import 'package:flutter/material.dart';

import 'package:vivia_mobile/features/premium/domain/models/payment_history_item.dart';

class PaymentDisplay {
  const PaymentDisplay._();

  static String date(DateTime? value) {
    if (value == null) return 'Sin fecha';
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d/$m/${value.year}';
  }

  static String amount(double value) =>
      '\$${value.toStringAsFixed(2)} MXN';

  static String statusLabel(PaymentStatus status) => switch (status) {
        PaymentStatus.pending => 'Pendiente',
        PaymentStatus.succeeded => 'Pagado',
        PaymentStatus.failed => 'Fallido',
        PaymentStatus.expired => 'Expirado',
      };

  static Color statusColor(PaymentStatus status) => switch (status) {
        PaymentStatus.pending => const Color(0xFFF59E0B),
        PaymentStatus.succeeded => const Color(0xFF16A34A),
        PaymentStatus.failed => const Color(0xFFDC2626),
        PaymentStatus.expired => const Color(0xFF6B7280),
      };
}

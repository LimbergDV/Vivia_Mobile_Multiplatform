import 'package:vivia_mobile/features/premium/domain/enums/payment_method.dart';

enum PaymentStatus {
  pending('pending'),
  succeeded('succeeded'),
  failed('failed'),
  expired('expired');

  final String apiValue;
  const PaymentStatus(this.apiValue);

  static PaymentStatus fromApi(String value) => values.firstWhere(
        (s) => s.apiValue == value,
        orElse: () => PaymentStatus.pending,
      );
}

class PaymentHistoryItem {
  final PaymentMethod method;
  final PaymentStatus status;
  final double amount;
  final String? reference;
  final DateTime? createdAt;

  const PaymentHistoryItem({
    required this.method,
    required this.status,
    required this.amount,
    this.reference,
    this.createdAt,
  });
}

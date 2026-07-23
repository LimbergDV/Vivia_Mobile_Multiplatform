import 'package:vivia_mobile/features/premium/domain/enums/payment_method.dart';
import 'package:vivia_mobile/features/premium/domain/models/payment_history_item.dart';

class PaymentHistoryItemModel {
  final String method;
  final String status;
  final double amount;
  final String? reference;
  final String? createdAt;

  const PaymentHistoryItemModel({
    required this.method,
    required this.status,
    required this.amount,
    this.reference,
    this.createdAt,
  });

  factory PaymentHistoryItemModel.fromJson(Map<String, dynamic> json) =>
      PaymentHistoryItemModel(
        method: json['method'] as String? ?? 'card',
        status: json['status'] as String? ?? 'pending',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        reference: json['reference'] as String?,
        createdAt: json['created_at'] as String?,
      );

  PaymentHistoryItem toDomain() => PaymentHistoryItem(
        method: PaymentMethod.fromApi(method),
        status: PaymentStatus.fromApi(status),
        amount: amount,
        reference: reference,
        createdAt:
            createdAt == null ? null : DateTime.tryParse(createdAt!)?.toLocal(),
      );
}

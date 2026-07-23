import 'package:vivia_mobile/features/premium/domain/models/checkout_session.dart';

class CheckoutSessionModel {
  final String checkoutUrl;
  final String? reference;
  final String? voucherUrl;

  const CheckoutSessionModel({
    required this.checkoutUrl,
    this.reference,
    this.voucherUrl,
  });

  factory CheckoutSessionModel.fromJson(Map<String, dynamic> json) =>
      CheckoutSessionModel(
        checkoutUrl: json['checkout_url'] as String? ?? '',
        reference: json['reference'] as String?,
        voucherUrl: json['voucher_url'] as String?,
      );

  CheckoutSession toDomain() => CheckoutSession(
        checkoutUrl: checkoutUrl,
        reference: reference,
        voucherUrl: voucherUrl,
      );
}

import 'package:vivia_mobile/features/premium/domain/enums/payment_method.dart';
import 'package:vivia_mobile/features/premium/domain/models/checkout_session.dart';
import 'package:vivia_mobile/features/premium/domain/models/payment_history_item.dart';
import 'package:vivia_mobile/features/premium/domain/models/premium_status.dart';

abstract class PremiumRepository {
  Future<CheckoutSession> createCheckout(PaymentMethod method);
  Future<PremiumStatus> getPremiumStatus();
  Future<List<PaymentHistoryItem>> getPaymentHistory();
}

import 'package:vivia_mobile/features/premium/data/datasources/remote/premium_remote_datasource.dart';
import 'package:vivia_mobile/features/premium/domain/enums/payment_method.dart';
import 'package:vivia_mobile/features/premium/domain/models/checkout_session.dart';
import 'package:vivia_mobile/features/premium/domain/models/payment_history_item.dart';
import 'package:vivia_mobile/features/premium/domain/models/premium_status.dart';
import 'package:vivia_mobile/features/premium/domain/repositories/premium_repository.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumRemoteDatasource _remote;

  PremiumRepositoryImpl({required PremiumRemoteDatasource remote})
      : _remote = remote;

  @override
  Future<CheckoutSession> createCheckout(PaymentMethod method) async {
    final model = await _remote.createCheckout(method.apiValue);
    return model.toDomain();
  }

  @override
  Future<PremiumStatus> getPremiumStatus() async {
    final model = await _remote.getPremiumStatus();
    return model.toDomain();
  }

  @override
  Future<List<PaymentHistoryItem>> getPaymentHistory() async {
    final models = await _remote.getPaymentHistory();
    return models.map((m) => m.toDomain()).toList();
  }
}

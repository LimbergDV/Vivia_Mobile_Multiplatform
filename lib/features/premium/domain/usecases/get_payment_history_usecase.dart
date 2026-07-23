import 'package:vivia_mobile/features/premium/domain/models/payment_history_item.dart';
import 'package:vivia_mobile/features/premium/domain/repositories/premium_repository.dart';

class GetPaymentHistoryUseCase {
  final PremiumRepository _repository;
  const GetPaymentHistoryUseCase(this._repository);

  Future<List<PaymentHistoryItem>> execute() =>
      _repository.getPaymentHistory();
}

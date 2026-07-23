import 'package:vivia_mobile/features/premium/domain/enums/payment_method.dart';
import 'package:vivia_mobile/features/premium/domain/models/checkout_session.dart';
import 'package:vivia_mobile/features/premium/domain/repositories/premium_repository.dart';

class CreateCheckoutUseCase {
  final PremiumRepository _repository;
  const CreateCheckoutUseCase(this._repository);

  Future<CheckoutSession> execute(PaymentMethod method) =>
      _repository.createCheckout(method);
}

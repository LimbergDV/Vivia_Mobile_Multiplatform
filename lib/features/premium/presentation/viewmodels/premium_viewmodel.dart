import 'package:flutter/foundation.dart';

import 'package:vivia_mobile/features/premium/domain/enums/payment_method.dart';
import 'package:vivia_mobile/features/premium/domain/models/checkout_session.dart';
import 'package:vivia_mobile/features/premium/domain/usecases/create_checkout_usecase.dart';
import 'package:vivia_mobile/features/premium/domain/usecases/get_premium_status_usecase.dart';

enum CheckoutStatus { idle, creating, error }

class PremiumViewModel extends ChangeNotifier {
  final GetPremiumStatusUseCase _getStatus;
  final CreateCheckoutUseCase _createCheckout;

  PremiumViewModel({
    required GetPremiumStatusUseCase getStatusUseCase,
    required CreateCheckoutUseCase createCheckoutUseCase,
  })  : _getStatus = getStatusUseCase,
        _createCheckout = createCheckoutUseCase;

  bool _isPremium = false;
  DateTime? _premiumUntil;
  bool _loading = false;
  CheckoutStatus _checkoutStatus = CheckoutStatus.idle;
  String? _checkoutError;
  PaymentMethod? _pendingMethod;

  bool get isPremium => _isPremium;
  DateTime? get premiumUntil => _premiumUntil;
  bool get loading => _loading;
  CheckoutStatus get checkoutStatus => _checkoutStatus;
  String? get checkoutError => _checkoutError;
  PaymentMethod? get pendingMethod => _pendingMethod;

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    try {
      final status = await _getStatus.execute();
      _isPremium = status.active;
      _premiumUntil = status.premiumUntil;
    } catch (_) {
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<CheckoutSession?> createCheckout(PaymentMethod method) async {
    if (_checkoutStatus == CheckoutStatus.creating) return null;
    _checkoutStatus = CheckoutStatus.creating;
    _pendingMethod = method;
    _checkoutError = null;
    notifyListeners();
    try {
      final session = await _createCheckout.execute(method);
      _checkoutStatus = CheckoutStatus.idle;
      notifyListeners();
      return session;
    } catch (e) {
      _checkoutStatus = CheckoutStatus.error;
      _checkoutError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  void clearCheckoutError() {
    _checkoutError = null;
    _checkoutStatus = CheckoutStatus.idle;
    notifyListeners();
  }

  void reset() {
    _isPremium = false;
    _premiumUntil = null;
    _loading = false;
    _checkoutStatus = CheckoutStatus.idle;
    _checkoutError = null;
    _pendingMethod = null;
    notifyListeners();
  }
}

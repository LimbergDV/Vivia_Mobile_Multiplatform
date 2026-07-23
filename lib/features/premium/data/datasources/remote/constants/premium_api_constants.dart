import 'package:vivia_mobile/features/auth/data/datasources/remote/constants/auth_api_constants.dart';

class PremiumApiConstants {
  PremiumApiConstants._();

  static String get _base => AuthApiConstants.baseUrl;

  static String get checkout => '$_base/payments/checkout';
  static String get subscriptionsMe => '$_base/subscriptions/me';
  static String get paymentsHistory => '$_base/payments/history';

  static Map<String, String> headers() => AuthApiConstants.headers();
}

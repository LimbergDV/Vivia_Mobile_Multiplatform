import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:vivia_mobile/features/premium/data/datasources/remote/constants/premium_api_constants.dart';
import 'package:vivia_mobile/features/premium/data/models/checkout_session_model.dart';
import 'package:vivia_mobile/features/premium/data/models/payment_history_item_model.dart';
import 'package:vivia_mobile/features/premium/data/models/premium_status_model.dart';

abstract class PremiumRemoteDatasource {
  Future<CheckoutSessionModel> createCheckout(String method);
  Future<PremiumStatusModel> getPremiumStatus();
  Future<List<PaymentHistoryItemModel>> getPaymentHistory();
}

class PremiumRemoteDatasourceImpl implements PremiumRemoteDatasource {
  final http.Client _client;
  static const _timeout = Duration(seconds: 20);

  PremiumRemoteDatasourceImpl(this._client);

  @override
  Future<CheckoutSessionModel> createCheckout(String method) async {
    final res = await _client
        .post(
          Uri.parse(PremiumApiConstants.checkout),
          headers: PremiumApiConstants.headers(),
          body: jsonEncode({'method': method}),
        )
        .timeout(_timeout);

    if (res.statusCode == 200 || res.statusCode == 201) {
      return CheckoutSessionModel.fromJson(_decode(res.body));
    }
    throw Exception(_errorMessage(res, 'No se pudo iniciar el pago'));
  }

  @override
  Future<PremiumStatusModel> getPremiumStatus() async {
    final res = await _client
        .get(
          Uri.parse(PremiumApiConstants.subscriptionsMe),
          headers: PremiumApiConstants.headers(),
        )
        .timeout(_timeout);

    final json = _decode(res.body);
    if (res.statusCode == 200 && json['success'] == true) {
      return PremiumStatusModel.fromJson(json);
    }
    throw Exception(_errorMessage(res, 'No se pudo consultar tu suscripción'));
  }

  @override
  Future<List<PaymentHistoryItemModel>> getPaymentHistory() async {
    final res = await _client
        .get(
          Uri.parse(PremiumApiConstants.paymentsHistory),
          headers: PremiumApiConstants.headers(),
        )
        .timeout(_timeout);

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list
          .map((e) =>
              PaymentHistoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_errorMessage(res, 'No se pudo obtener el historial'));
  }

  Map<String, dynamic> _decode(String body) =>
      body.isEmpty ? const {} : jsonDecode(body) as Map<String, dynamic>;

  String _errorMessage(http.Response res, String fallback) {
    try {
      final json = _decode(res.body);
      return json['message'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}

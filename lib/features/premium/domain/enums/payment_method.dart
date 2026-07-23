enum PaymentMethod {
  card('card', 'Tarjeta'),
  oxxo('oxxo', 'Efectivo OXXO'),
  spei('spei', 'Transferencia SPEI');

  final String apiValue;
  final String label;

  const PaymentMethod(this.apiValue, this.label);

  bool get isInstant => this == PaymentMethod.card;

  static PaymentMethod fromApi(String value) => values.firstWhere(
        (m) => m.apiValue == value,
        orElse: () => PaymentMethod.card,
      );
}

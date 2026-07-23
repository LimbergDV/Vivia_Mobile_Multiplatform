class CheckoutSession {
  final String checkoutUrl;
  final String? reference;
  final String? voucherUrl;

  const CheckoutSession({
    required this.checkoutUrl,
    this.reference,
    this.voucherUrl,
  });
}

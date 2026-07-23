class PremiumRequiredException implements Exception {
  final String message;

  const PremiumRequiredException([
    this.message =
        'Alcanzaste el límite gratuito. Suscríbete a Premium para continuar.',
  ]);

  @override
  String toString() => message;
}

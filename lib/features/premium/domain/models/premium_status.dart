class PremiumStatus {
  final bool active;
  final DateTime? premiumUntil;

  const PremiumStatus({required this.active, this.premiumUntil});

  const PremiumStatus.free() : active = false, premiumUntil = null;
}

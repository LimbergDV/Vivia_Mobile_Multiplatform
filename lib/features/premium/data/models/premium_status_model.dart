import 'package:vivia_mobile/features/premium/domain/models/premium_status.dart';

class PremiumStatusModel {
  final bool active;
  final String? premiumUntil;

  const PremiumStatusModel({required this.active, this.premiumUntil});

  factory PremiumStatusModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    return PremiumStatusModel(
      active: data['active'] as bool? ?? false,
      premiumUntil: data['premiumUntil'] as String?,
    );
  }

  PremiumStatus toDomain() => PremiumStatus(
        active: active,
        premiumUntil: premiumUntil == null
            ? null
            : DateTime.tryParse(premiumUntil!)?.toLocal(),
      );
}

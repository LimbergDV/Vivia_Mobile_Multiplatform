import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  double _completionPercent;
  bool _isVerified;
  bool _isPremium;
  bool _hasPersonalInfoPending;
  bool _hasPaymentInfoPending;

  ProfileViewModel({
    double completionPercent = 0.75,
    bool isVerified = false,
    bool isPremium = false,
    bool hasPersonalInfoPending = true,
    bool hasPaymentInfoPending = true,
  })  : _completionPercent = completionPercent,
        _isVerified = isVerified,
        _isPremium = isPremium,
        _hasPersonalInfoPending = hasPersonalInfoPending,
        _hasPaymentInfoPending = hasPaymentInfoPending;

  double get completionPercent => _completionPercent;
  bool get isVerified => _isVerified;
  bool get isPremium => _isPremium;
  bool get hasPersonalInfoPending => _hasPersonalInfoPending;
  bool get hasPaymentInfoPending => _hasPaymentInfoPending;
  int get completionPercentInt => (_completionPercent * 100).round();
}
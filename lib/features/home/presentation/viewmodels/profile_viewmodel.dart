import 'package:flutter/material.dart';

import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vivia_mobile/features/user/domain/usecases/get_profile_usecase.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetProfileUseCase _getProfileUseCase;
  final AuthRepository _authRepository;

  ProfileViewModel({
    required GetProfileUseCase getProfileUseCase,
    required AuthRepository authRepository,
  })  : _getProfileUseCase = getProfileUseCase,
        _authRepository = authRepository;

  String _displayName = '';
  String? _avatarUrl;
  bool _isVerified = false;
  bool _isLoading = false;

  final double _completionPercent = 0.75;
  final bool _hasPersonalInfoPending = true;
  final bool _hasPaymentInfoPending = true;

  String get displayName => _displayName;
  String? get avatarUrl => _avatarUrl;
  bool get isVerified => _isVerified;
  bool get isLoading => _isLoading;

  double get completionPercent => _completionPercent;
  int get completionPercentInt => (_completionPercent * 100).round();
  bool get hasPersonalInfoPending => _hasPersonalInfoPending;
  bool get hasPaymentInfoPending => _hasPaymentInfoPending;

  bool get isLessor => _authRepository.savedRole == 'ROLE_LESSOR';

  // Reglas de negocio por rol
  bool get showVerifiedBadge => isLessor && _isVerified;
  bool get showSubscriptionBanner => isLessor;
  bool get showPaymentMethods => isLessor;
  bool get showVerifyAccount => isLessor;

  /// Inicializa con datos seed (login) y dispara el fetch del perfil completo.
  void init(String seedName, String? seedAvatarUrl) {
    _displayName = seedName;
    _avatarUrl = seedAvatarUrl;
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final profile = await _getProfileUseCase.execute();
      _displayName = profile.fullName;
      _avatarUrl = profile.photoUrl;
      _isVerified = profile.isVerified;
    } catch (_) {
      // Silencioso: se conserva el seed del login.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

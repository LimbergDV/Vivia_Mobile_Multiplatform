import 'package:flutter/material.dart';

import 'package:vivia_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vivia_mobile/features/user/domain/models/full_profile.dart';
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
  FullProfile? _profile;

  String get displayName => _displayName;
  String? get avatarUrl => _avatarUrl;
  bool get isVerified => _isVerified;
  bool get isLoading => _isLoading;
  FullProfile? get profile => _profile;

  List<bool> get _personalChecklist {
    final p = _profile;
    if (p == null) return const [];
    return [
      p.name.trim().isNotEmpty,
      p.paternalSurname.trim().isNotEmpty,
      p.email.trim().isNotEmpty,
      p.photoUrl?.isNotEmpty ?? false,
      _roleFieldComplete(p),
    ];
  }

  bool _roleFieldComplete(FullProfile p) => isLessor
      ? (p.phoneNumber?.trim().isNotEmpty ?? false)
      : (p.latitude != null && p.longitude != null);

  List<bool> get _completionChecklist {
    final personal = _personalChecklist;
    if (personal.isEmpty) return const [];
    return [...personal, if (isLessor) _isVerified];
  }

  double get completionPercent {
    final items = _completionChecklist;
    if (items.isEmpty) return 0;
    return items.where((done) => done).length / items.length;
  }

  int get completionPercentInt => (completionPercent * 100).round();
  bool get isProfileComplete => _profile != null && completionPercent >= 1.0;
  bool get hasPersonalInfoPending => _personalChecklist.contains(false);
  bool get hasVerificationPending => isLessor && !_isVerified;
  bool get hasPaymentInfoPending => false;

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

  /// Re-consulta el perfil (p. ej. al volver de editar información personal).
  Future<void> refresh() => _fetchProfile();

  Future<void> _fetchProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final profile = await _getProfileUseCase.execute();
      _profile = profile;
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

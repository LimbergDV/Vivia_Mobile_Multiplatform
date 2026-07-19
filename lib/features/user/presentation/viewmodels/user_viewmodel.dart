import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:vivia_mobile/features/user/domain/usecases/get_me_usecase.dart';

enum UserProfileStatus { idle, loading, success, error }

class UserViewModel extends ChangeNotifier {
  final GetMeUseCase _getMeUseCase;
  final AuthLocalDatasource _local;

  UserViewModel({
    required GetMeUseCase getMeUseCase,
    required AuthLocalDatasource local,
  })  : _getMeUseCase = getMeUseCase,
        _local = local;

  UserProfileStatus _status = UserProfileStatus.idle;
  String _displayName = '';
  String? _avatarUrl;

  UserProfileStatus get status => _status;
  String get displayName => _displayName;
  String? get avatarUrl => _avatarUrl;

  /// Inicializa el header con datos del login (seed) y dispara el fetch en background.
  /// Llamar desde addPostFrameCallback para evitar notifyListeners durante build.
  void init(String seedName, String? seedAvatarUrl) {
    _displayName = seedName;
    _avatarUrl = seedAvatarUrl;
    notifyListeners();
    _fetchMe();
  }

  Future<void> _fetchMe() async {
    _status = UserProfileStatus.loading;
    notifyListeners();
    try {
      final profile = await _getMeUseCase.execute();
      if (profile.id != null) await _local.saveUserId(profile.id!);
      _displayName = profile.name;
      _avatarUrl = profile.photoUrl;
      _status = UserProfileStatus.success;
    } catch (_) {
      _status = UserProfileStatus.error;
    } finally {
      notifyListeners();
    }
  }
}

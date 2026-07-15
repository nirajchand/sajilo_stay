import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/services/hive/hive_service.dart';
import 'package:sajilo_stay/core/services/storage/user_session_service.dart';
import 'package:sajilo_stay/features/auth/data/datasources/auth_datasource.dart';
import 'package:sajilo_stay/features/auth/data/models/auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      if (user != null) {
        await _userSessionService.saveUserSession(
          userId: user.userId!,
          email: user.email,
          fullName: user.fullName,
          role: user.userType,
        );
      }
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel> registerUser(AuthHiveModel user) async {
    await _hiveService.registerUser(user);
    return user;
  }

  @override
  Future<bool> logout() async {
    try {
      await _userSessionService.clearSession();
      return true;
    } catch (_) {
      return false;
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'userId';
  static const String _keyUserEmail = 'email';
  static const String _keyUserFullName = 'fullName';
  static const String _keyRole = "role";
  static const String _keyProfileImagePath = 'profile_image_path';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    required String role,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserFullName, fullName);
    await _prefs.setString(_keyRole, role);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  String? getCurrentUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  String? getCurrentUserFullName() {
    return _prefs.getString(_keyUserFullName);
  }

  String? getRole() {
    return _prefs.getString(_keyRole);
  }

  Future<void> saveProfileImagePath(String path) async {
    await _prefs.setString(_keyProfileImagePath, path);
  }

  String? getProfileImagePath() {
    return _prefs.getString(_keyProfileImagePath);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserFullName);
    await _prefs.remove(_keyRole);
    await _prefs.remove(_keyProfileImagePath);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/api/api_endpoints.dart';
import 'package:sajilo_stay/core/api/app_client.dart';
import 'package:sajilo_stay/core/services/storage/token_service.dart';
import 'package:sajilo_stay/core/services/storage/user_session_service.dart';
import 'package:sajilo_stay/features/auth/data/datasources/auth_datasource.dart';
import 'package:sajilo_stay/features/auth/data/models/auth_api_model.dart';

final authRemoteProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService,
        _tokenService = tokenService;

  @override
  Future<AuthApiModel?> loginUser(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final userMap = response.data['user'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(userMap);

      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String? ?? '';

      await _tokenService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      await _userSessionService.saveUserSession(
        userId: user.id ?? '',
        email: user.email,
        fullName: user.fullName,
        role: user.role,
      );

      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel> registerUser(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );

    if (response.data['success'] == true) {
      final userMap = response.data['user'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(userMap);
    }
    return user;
  }

  @override
  Future<AuthApiModel> googleSignIn(String idToken) async {
    final response = await _apiClient.post(
      ApiEndpoints.googleAuth,
      data: {'idToken': idToken},
    );

    if (response.data['success'] == true) {
      final userMap = response.data['user'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(userMap);

      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String? ?? '';

      await _tokenService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      await _userSessionService.saveUserSession(
        userId: user.id ?? '',
        email: user.email,
        fullName: user.fullName,
        role: user.role,
      );

      return user;
    }
    throw Exception('Google sign-in failed');
  }

  @override
  Future<bool> sendToken(String email) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('sendToken error: $e');
      return false;
    }
  }

  @override
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('verifyOtp error: $e');
      return false;
    }
  }

  @override
  Future<bool> resetToken(String email, String newPassword) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {'email': email, 'newPassword': newPassword},
      );
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('resetToken error: $e');
      return false;
    }
  }
}

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sajilo_stay/core/api/api_endpoints.dart';
import 'package:sajilo_stay/core/navigation/app_navigator.dart';
import 'package:sajilo_stay/core/services/storage/token_service.dart';
import 'package:sajilo_stay/core/services/storage/user_session_service.dart';
import 'package:sajilo_stay/features/auth/presentation/pages/login_screen.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    tokenService: ref.read(tokenServiceProvider),
    onSessionExpired: () async {
      // Wipe credentials, then bounce to the login screen, clearing the stack.
      await ref.read(tokenServiceProvider).clearTokens();
      await ref.read(userSessionServiceProvider).clearSession();
      _redirectToLogin();
    },
  );
});

// Guards against stacking multiple login screens when several requests 401 at
// once. Reset once we're back on the login screen.
bool _redirecting = false;

void _redirectToLogin() {
  if (_redirecting) return;
  _redirecting = true;
  final nav = navigatorKey.currentState;
  if (nav == null) {
    _redirecting = false;
    return;
  }
  nav.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
  _redirecting = false;
}

class ApiClient {
  late final Dio _dio;
  final TokenService _tokenService;
  final Future<void> Function() _onSessionExpired;

  ApiClient({
    required TokenService tokenService,
    required Future<void> Function() onSessionExpired,
  })  : _tokenService = tokenService,
        _onSessionExpired = onSessionExpired {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': "application/json",
          'Accept': "application/json",
        },
      ),
    );

    _dio.interceptors.add(
      _AuthInterceptor(
        dio: _dio,
        tokenService: _tokenService,
        onSessionExpired: _onSessionExpired,
      ),
    );

    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 1,
        retryDelays: const [
          Duration(seconds: 1),
        ],
        retryEvaluator: (error, attempt) {
          // Only retry transient send/receive timeouts. A connectionError /
          // connectionTimeout usually means the server is down or the host is
          // wrong — retrying just hangs the UI, so surface it immediately.
          return error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout;
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: true,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> postForm(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> updateFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    return _dio.put(
      path,
      data: formData,
      options: options,
      onSendProgress: onSendProgress,
    );
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenService _tokenService;
  final Future<void> Function() _onSessionExpired;

  _AuthInterceptor({
    required Dio dio,
    required TokenService tokenService,
    required Future<void> Function() onSessionExpired,
  })  : _dio = dio,
        _tokenService = tokenService,
        _onSessionExpired = onSessionExpired;

  static const _retriedFlag = '__auth_retried__';

  bool _isAuthEndpoint(String path) =>
      path == ApiEndpoints.register ||
      path == ApiEndpoints.login ||
      path == ApiEndpoints.refresh;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthEndpoint(options.path)) {
      final token = await _tokenService.getAccessToken();
      if (token != null) {
        options.headers["Authorization"] = "Bearer $token";
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final is401 = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[_retriedFlag] == true;

    // Only act on auth failures from protected endpoints, once per request.
    if (!is401 || alreadyRetried || _isAuthEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }

    // 1. Try to silently refresh the access token using the refresh token.
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _onSessionExpired();
      return handler.next(err);
    }

    final newAccessToken = await _tryRefresh(refreshToken);
    if (newAccessToken == null) {
      // Refresh token is expired/invalid → session is truly over.
      await _onSessionExpired();
      return handler.next(err);
    }

    // 2. Replay the original request with the fresh token.
    try {
      final options = err.requestOptions;
      options.headers["Authorization"] = "Bearer $newAccessToken";
      options.extra[_retriedFlag] = true;
      final response = await _dio.fetch(options);
      return handler.resolve(response);
    } catch (e) {
      if (e is DioException) return handler.next(e);
      return handler.next(err);
    }
  }

  /// Exchanges a refresh token for a new access token. Uses a bare Dio so this
  /// call doesn't loop back through this interceptor. Returns null on failure.
  Future<String?> _tryRefresh(String refreshToken) async {
    try {
      final bare = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: ApiEndpoints.connectionTimeout,
          receiveTimeout: ApiEndpoints.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      final response = await bare.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      if (response.data is Map && response.data['success'] == true) {
        final newAccess = response.data['accessToken'] as String?;
        if (newAccess != null && newAccess.isNotEmpty) {
          // Backend doesn't rotate the refresh token, so keep the existing one.
          await _tokenService.saveTokens(
            accessToken: newAccess,
            refreshToken: refreshToken,
          );
          return newAccess;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

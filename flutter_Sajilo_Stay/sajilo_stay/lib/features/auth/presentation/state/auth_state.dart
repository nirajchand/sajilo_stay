import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sajilo_stay/features/auth/data/repositories/auth_repository.dart';
import 'package:sajilo_stay/features/auth/domain/entities/auth_entity.dart';
import 'package:sajilo_stay/core/services/storage/token_service.dart';
import 'package:sajilo_stay/core/services/storage/user_session_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AuthEntity? user;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(AuthEntity user) =>
      AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() =>
      AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.error(String message) =>
      AuthState(status: AuthStatus.error, errorMessage: message);
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final sessionService = ref.read(userSessionServiceProvider);
    if (sessionService.isLoggedIn()) {
      return AuthState.authenticated(
        AuthEntity(
          userId: sessionService.getCurrentUserId(),
          fullName: sessionService.getCurrentUserFullName() ?? '',
          email: sessionService.getCurrentUserEmail() ?? '',
          userType: sessionService.getRole() ?? 'USER',
        ),
      );
    }
    return AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.loginUser(email, password);
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) async {
        final session = ref.read(userSessionServiceProvider);
        await session.saveUserSession(
          userId: user.userId ?? '',
          email: user.email,
          fullName: user.fullName,
          role: user.userType,
        );
        state = AuthState.authenticated(user);
      },
    );
  }

  Future<void> register(
      String fullName, String email, String password) async {
    state = AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    final entity = AuthEntity(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: password,
      userType: 'USER',
    );
    final result = await repository.registerUser(entity);
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) => state = AuthState.unauthenticated(),
    );
  }

  Future<void> loginWithGoogle() async {
    state = AuthState.loading();
    try {
      // Trigger the Google account picker.
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null) {
        state = AuthState.error(
          'Google Sign-In: could not get ID token. '
          'Ensure Firebase Authentication → Google is enabled in the console.',
        );
        return;
      }

      final repository = ref.read(authRepositoryProvider);
      final result = await repository.loginWithGoogle(idToken);

      result.fold(
        (failure) => state = AuthState.error(failure.message),
        (user) async {
          final session = ref.read(userSessionServiceProvider);
          await session.saveUserSession(
            userId: user.userId ?? '',
            email: user.email,
            fullName: user.fullName,
            role: user.userType,
          );
          state = AuthState.authenticated(user);
        },
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        state = AuthState.unauthenticated();
      } else {
        state = AuthState.error('Google Sign-In failed: ${e.description ?? e.code.name}');
      }
    } catch (e) {
      state = AuthState.error('Google Sign-In failed: $e');
    }
  }

  Future<void> logout() async {
    state = AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.logout();
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) async {
        final session = ref.read(userSessionServiceProvider);
        final tokens = ref.read(tokenServiceProvider);
        await session.clearSession();
        await tokens.clearTokens();
        state = AuthState.unauthenticated();
      },
    );
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

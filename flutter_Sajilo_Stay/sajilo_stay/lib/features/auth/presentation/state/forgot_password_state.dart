import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/features/auth/data/repositories/auth_repository.dart';

enum ForgotPasswordStatus { initial, loading, otpSent, otpVerified, error }

class ForgotPasswordState {
  final ForgotPasswordStatus status;
  final String? email;
  final String? errorMessage;

  const ForgotPasswordState({
    required this.status,
    this.email,
    this.errorMessage,
  });

  factory ForgotPasswordState.initial() =>
      const ForgotPasswordState(status: ForgotPasswordStatus.initial);

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    String? email,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => ForgotPasswordState.initial();

  /// Requests a reset OTP to be emailed to [email]. Returns true on success.
  Future<bool> sendOtp(String email) async {
    state = state.copyWith(
      status: ForgotPasswordStatus.loading,
      email: email,
    );
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.sendToken(email);
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ForgotPasswordStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          status: ForgotPasswordStatus.otpSent,
          email: email,
        );
        return true;
      },
    );
  }

  /// Verifies the entered [otp] against the email stored in state.
  Future<bool> verifyOtp(String otp) async {
    final email = state.email;
    if (email == null) return false;
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.verifyOtp(email, otp);
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ForgotPasswordStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: ForgotPasswordStatus.otpVerified);
        return true;
      },
    );
  }

  /// Sets a new password for the (already OTP-verified) email. Returns true on success.
  Future<bool> resetPassword(String newPassword) async {
    final email = state.email;
    if (email == null) return false;
    state = state.copyWith(status: ForgotPasswordStatus.loading);
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.resetPassword(email, newPassword);
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ForgotPasswordStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = ForgotPasswordState.initial();
        return true;
      },
    );
  }
}

final forgotPasswordProvider =
    NotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
  () => ForgotPasswordNotifier(),
);

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/core/utils/snackbar_utils.dart';
import 'package:sajilo_stay/features/auth/presentation/pages/new_password_screen.dart';
import 'package:sajilo_stay/features/auth/presentation/state/forgot_password_state.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends ConsumerState<OtpVerificationScreen> {
  final List<String> _digits = ['', '', '', ''];
  int _secondsLeft = 59;
  Timer? _countdownTimer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() => _secondsLeft = 59);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _onDigitTap(String digit) {
    final firstEmpty = _digits.indexWhere((d) => d.isEmpty);
    if (firstEmpty == -1) return;
    setState(() => _digits[firstEmpty] = digit);
  }

  void _onBackspace() {
    final lastFilled = _digits.lastIndexWhere((d) => d.isNotEmpty);
    if (lastFilled == -1) return;
    setState(() => _digits[lastFilled] = '');
  }

  Future<void> _handleSubmit() async {
    final code = _digits.join();
    if (code.length < 4) {
      SnackbarUtils.showError(
          context, 'Please enter the complete 4-digit code.');
      return;
    }
    setState(() => _isVerifying = true);
    final isValid =
        await ref.read(forgotPasswordProvider.notifier).verifyOtp(code);
    if (!mounted) return;
    setState(() => _isVerifying = false);
    if (isValid) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NewPasswordScreen()),
      );
    } else {
      final error =
          ref.read(forgotPasswordProvider).errorMessage ?? 'Invalid code. Please try again.';
      SnackbarUtils.showError(context, error);
    }
  }

  Future<void> _handleResend() async {
    final sent =
        await ref.read(forgotPasswordProvider.notifier).sendOtp(widget.email);
    if (!mounted) return;
    if (sent) {
      setState(() => _digits.setAll(0, ['', '', '', '']));
      _startTimer();
      SnackbarUtils.showSuccess(context, 'A new code has been sent.');
    } else {
      final error = ref.read(forgotPasswordProvider).errorMessage;
      SnackbarUtils.showError(
          context, error ?? 'Could not resend code. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filledCount = _digits.where((d) => d.isNotEmpty).length;
    final timerText =
        'Resend Code in 00:${_secondsLeft.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // Midnight Forest ambient glow — large radial green bloom at top
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      kSurfaceLevel2,
                      kBackgroundColor,
                    ],
                    stops: const [0.0, 1.0],
                    radius: 0.7,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kAccentColor.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _BackButton(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Verification\nCode',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: kSecondaryColor,
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'We have sent a code verification to your\nemail address',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: kNeutralColor,
                                  ),
                        ),
                        const SizedBox(height: 36),
                        // OTP Boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
                            (i) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: _OtpBox(digit: _digits[i]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Timer / Resend
                        Center(
                          child: GestureDetector(
                            onTap: _secondsLeft == 0 ? _handleResend : null,
                            child: Text(
                              _secondsLeft > 0 ? timerText : 'Resend Code',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: _secondsLeft > 0
                                        ? kNeutralColor
                                        : kAccentColor,
                                    fontWeight: _secondsLeft == 0
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Custom numpad + submit
                _NumPad(
                  onDigit: _onDigitTap,
                  onBackspace: _onBackspace,
                  onSubmit: filledCount == 4 && !_isVerifying
                      ? _handleSubmit
                      : null,
                  isVerifying: _isVerifying,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── OTP Box ──────────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final String digit;
  const _OtpBox({required this.digit});

  @override
  Widget build(BuildContext context) {
    final bool filled = digit.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: filled
              ? kAccentColor.withValues(alpha: 0.6)
              : kNeutralColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Center(
        child: filled
            ? Text(
                digit,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: kSecondaryColor,
                ),
              )
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kNeutralColor.withValues(alpha: 0.3),
                ),
              ),
      ),
    );
  }
}

// ── Custom Numpad ─────────────────────────────────────────────────────────────

class _NumPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onSubmit;
  final bool isVerifying;

  const _NumPad({
    required this.onDigit,
    required this.onBackspace,
    required this.onSubmit,
    required this.isVerifying,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Column(
        children: [
          _KeyRow(keys: ['1', '2', '3'], onDigit: onDigit),
          const SizedBox(height: 8),
          _KeyRow(keys: ['4', '5', '6'], onDigit: onDigit),
          const SizedBox(height: 8),
          _KeyRow(keys: ['7', '8', '9'], onDigit: onDigit),
          const SizedBox(height: 8),
          Row(
            children: [
              // Empty placeholder
              const Expanded(child: SizedBox()),
              const SizedBox(width: 8),
              Expanded(
                child: _NumKey(label: '0', onTap: () => onDigit('0')),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BackspaceKey(onTap: onBackspace),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: onSubmit != null
                    ? kSecondaryColor
                    : kSurfaceLevel1,
                foregroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onSubmit,
              child: isVerifying
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Submit',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: onSubmit != null
                            ? kPrimaryColor
                            : kNeutralColor,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyRow extends StatelessWidget {
  final List<String> keys;
  final void Function(String) onDigit;
  const _KeyRow({required this.keys, required this.onDigit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _NumKey(label: keys[i], onTap: () => onDigit(keys[i])),
          ),
        ],
      ],
    );
  }
}

class _NumKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NumKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: kSurfaceLevel1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: kSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _BackspaceKey extends StatelessWidget {
  final VoidCallback onTap;
  const _BackspaceKey({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: kSurfaceLevel1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.backspace_outlined, color: kSecondaryColor, size: 20),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: kSurfaceLevel1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: kSecondaryColor, size: 16),
      ),
    );
  }
}

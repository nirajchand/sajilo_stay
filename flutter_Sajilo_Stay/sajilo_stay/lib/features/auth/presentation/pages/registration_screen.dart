import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/core/utils/snackbar_utils.dart';
import 'package:sajilo_stay/features/auth/presentation/state/auth_state.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeTerms) {
        SnackbarUtils.showWarning(context, 'You must agree to the Terms & Conditions');
        return;
      }
      ref.read(authStateProvider.notifier).register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to authentication state changes
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated && previous?.status == AuthStatus.loading) {
        SnackbarUtils.showSuccess(context, 'Account created successfully! Please login.');
        Navigator.of(context).pop(); // Go back to login screen
      } else if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(context, next.errorMessage ?? 'Registration failed');
      }
    });

    final authState = ref.watch(authStateProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kAccentColor.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            top: 350,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryDimColor.withOpacity(0.03),
              ),
            ),
          ),

          // Main Registration Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20.0),

                      // Brand Identity Pill (Stitch layout)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: kSurfaceLevel1,
                          border: Border.all(color: kNeutralColor.withOpacity(0.15)),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: const Text(
                          'Sajilo Stay',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 20.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: kSecondaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Headline
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Your Account',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: kSecondaryColor,
                                  ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Enter your details to join our exclusive community of travelers.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: kNeutralColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36.0),

                      // Full Name Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                            child: Text(
                              'Full Name',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: const Color(0xFFC3C8C3),
                                  ),
                            ),
                          ),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14.0,
                              color: kSecondaryColor,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'John Doe',
                              prefixIcon: Icon(Icons.person_outline, size: 20.0, color: kNeutralColor),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              if (value.trim().length < 3) {
                                return 'Name must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),

                      // Email Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                            child: Text(
                              'Email Address',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: const Color(0xFFC3C8C3),
                                  ),
                            ),
                          ),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14.0,
                              color: kSecondaryColor,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'john@example.com',
                              prefixIcon: Icon(Icons.mail_outlined, size: 20.0, color: kNeutralColor),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),

                      // Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                            child: Text(
                              'Password',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: const Color(0xFFC3C8C3),
                                  ),
                            ),
                          ),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14.0,
                              color: kSecondaryColor,
                            ),
                            decoration: InputDecoration(
                              hintText: '••••••••••••',
                              prefixIcon: const Icon(Icons.lock_outline, size: 20.0, color: kNeutralColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: kNeutralColor,
                                  size: 20.0,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Terms & Conditions row
                      Row(
                        children: [
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: kNeutralColor,
                            ),
                            child: Checkbox(
                              value: _agreeTerms,
                              activeColor: kPrimaryDimColor,
                              checkColor: kPrimaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              onChanged: (value) {
                                setState(() {
                                    _agreeTerms = value ?? false;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreeTerms = !_agreeTerms;
                                });
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFFC3C8C3),
                                      ),
                                  children: const [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: TextStyle(
                                        color: kPrimaryDimColor,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 56.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSecondaryColor,
                            foregroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          onPressed: isLoading ? null : _handleSignUp,
                          child: isLoading
                              ? const SizedBox(
                                  width: 24.0,
                                  height: 24.0,
                                  child: CircularProgressIndicator(
                                    color: kPrimaryColor,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // OR divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFF434845), thickness: 0.5)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'OR CONTINUE WITH',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: kNeutralColor,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFF434845), thickness: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 20.0),

                      // Grid social buttons (Google & Facebook side-by-side as per Stitch)
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50.0,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: kSurfaceLevel2.withOpacity(0.3),
                                  side: BorderSide(color: kNeutralColor.withOpacity(0.2)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  SnackbarUtils.showInfo(context, 'Google Sign-In functionality stubbed.');
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/google_icon.png", width: 20.0, height: 20.0),
                                    const SizedBox(width: 8.0),
                                    const Text('Google'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                        ],
                      ),
                      const SizedBox(height: 40.0),

                      // Footer Navigation back to Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: kNeutralColor,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: kSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

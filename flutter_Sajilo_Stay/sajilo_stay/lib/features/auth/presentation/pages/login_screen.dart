import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/core/utils/snackbar_utils.dart';
import 'package:sajilo_stay/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:sajilo_stay/features/auth/presentation/pages/registration_screen.dart';
import 'package:sajilo_stay/features/auth/presentation/state/auth_state.dart';
import 'package:sajilo_stay/features/dashboard/presentation/pages/dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authStateProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to authentication state changes
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        SnackbarUtils.showSuccess(
          context,
          'Welcome back, ${next.user?.fullName}!',
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'Authentication failed',
        );
      }
    });

    final authState = ref.watch(authStateProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryDimColor.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kAccentColor.withOpacity(0.04),
              ),
            ),
          ),

          // Main Login Content
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

                      // Logo Section
                      Container(
                        width: 96.0,
                        height: 96.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBqSXPYrVDvhg-srAK4ggapXZBTjU1CZUP1VW6ndVJY1Qc4rOUNSJ-IVnRcfNsrxjYnAP-UG-XhLr74R67yIjrwI0W3mEeJ8JMw5BwycOIBEdXP1LTaYpKzk9XCFi_bnJXpc6VNoMR-FupQzuQs9OxnDXZIXkf1jTaM7kstsRknYq2yfctn95k-skp7zdbS8Wtd6Q-5SkDLmFBOUpidMBD6kcOuZy65uoACnEP7DvecAmw1W58VAYaigD2g8q6icBOH66mMZLA2XUc',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Headline
                      Text(
                        'Hello, Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: kSecondaryColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Login to your account below',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: kNeutralColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40.0),

                      // Email Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4.0,
                              bottom: 8.0,
                            ),
                            child: Text(
                              'Email Address',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: const Color(0xFFC3C8C3)),
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
                              hintText: 'mohamedkhhenedy@gmail.com',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
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
                            padding: const EdgeInsets.only(
                              left: 4.0,
                              bottom: 8.0,
                            ),
                            child: Text(
                              'Password',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: const Color(0xFFC3C8C3)),
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
                              hintText: 'Enter your password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
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
                                return 'Please enter your password';
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

                      // Actions Row (Remember Me & Forgot Password)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: kNeutralColor,
                                ),
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: kPrimaryDimColor,
                                  checkColor: kPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                child: Text(
                                  'Remember Me',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: const Color(0xFFC3C8C3),
                                      ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryDimColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Login Button
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
                          onPressed: isLoading ? null : _handleLogin,
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
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32.0),

                      // Or login with divider
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: Color(0xFF434845),
                              thickness: 0.5,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              'OR LOGIN WITH',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: kNeutralColor,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: Color(0xFF434845),
                              thickness: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Social Logins (Google)
                      SizedBox(
                        width: double.infinity,
                        height: 54.0,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: kSurfaceLevel2.withOpacity(0.3),
                            side: BorderSide(
                              color: kNeutralColor.withOpacity(0.2),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () => ref
                                    .read(authStateProvider.notifier)
                                    .loginWithGoogle(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google_icon.png',
                                width: 20.0,
                                height: 20.0,
                              ),
                              const SizedBox(width: 12.0),
                              const Text('Login With Google'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Footer Navigation to Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't have an account?",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: kNeutralColor),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Signup',
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/features/auth/presentation/pages/login_screen.dart';
import 'package:sajilo_stay/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:sajilo_stay/features/auth/presentation/state/auth_state.dart';
import 'package:sajilo_stay/features/auth/presentation/state/onboarding_state.dart';
import 'package:sajilo_stay/features/dashboard/presentation/pages/dashboard_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.85;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _navigateToNext();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });
  }

  void _navigateToNext() {
    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      final onboardingCompleted = ref.read(onboardingCompletedProvider);
      final authState = ref.read(authStateProvider);

      if (!onboardingCompleted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else if (authState.status == AuthStatus.authenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // Ambient backlighting glow
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryDimColor.withOpacity(0.04),
              ),
            ),
          ),

          // Central Logo and branding
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutBack,
              transform: Matrix4.identity()..scale(_scale),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _opacity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Icon
                    Container(
                      width: 110.0,
                      height: 110.0,
                      decoration: BoxDecoration(
                        color: kSurfaceLevel1,
                        borderRadius: BorderRadius.circular(28.0),
                        border: Border.all(
                          color: kNeutralColor.withOpacity(0.1),
                          width: 1.0,
                        ),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBqSXPYrVDvhg-srAK4ggapXZBTjU1CZUP1VW6ndVJY1Qc4rOUNSJ-IVnRcfNsrxjYnAP-UG-XhLr74R67yIjrwI0W3mEeJ8JMw5BwycOIBEdXP1LTaYpKzk9XCFi_bnJXpc6VNoMR-FupQzuQs9OxnDXZIXkf1jTaM7kstsRknYq2yfctn95k-skp7zdbS8Wtd6Q-5SkDLmFBOUpidMBD6kcOuZy65uoACnEP7DvecAmw1W58VAYaigD2g8q6icBOH66mMZLA2XUc',
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // App Title
                    const Text(
                      'Sajilo Stay',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 32.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        color: kSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Tagline
                    Text(
                      'Luxurious stays made simple',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: kNeutralColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Indicator at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    color: kNeutralColor.withOpacity(0.5),
                    strokeWidth: 2.0,
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

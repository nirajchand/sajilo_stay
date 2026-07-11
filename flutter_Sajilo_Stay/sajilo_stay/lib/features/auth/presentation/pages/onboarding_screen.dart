import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/features/auth/presentation/pages/login_screen.dart';
import 'package:sajilo_stay/features/auth/presentation/state/onboarding_state.dart';
import 'package:sajilo_stay/features/auth/presentation/widgets/onboarding_dot_indicator.dart';
import 'package:sajilo_stay/features/auth/presentation/widgets/onboarding_nav_button.dart';
import 'package:sajilo_stay/features/auth/presentation/widgets/onboarding_page_content.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  // Premium background images corresponding to onboarding slides
  final List<String> _backgroundImages = [
    // Page 1: Cinematic luxury villa in forest at twilight
    'https://images.unsplash.com/photo-1540541338287-41700207dee6?auto=format&fit=crop&w=1200&q=80',
    // Page 2: Contemporary suite booking context
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1200&q=80',
    // Page 3: Intimate cozy cabin in deep woods under night stars
    'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=1200&q=80',
  ];

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Find the Perfect Stay for Every Journey',
      'description':
          'Explore handpicked hotels, resorts, and stays tailored to your style, budget, & destination.',
    },
    {
      'title': 'Seamless & Secure Booking',
      'description':
          'Book your ideal stay in a few taps. Secure payments, instant confirmation, and hassle-free management.',
    },
    {
      'title': 'Immerse in Local Experiences',
      'description':
          'Get curated recommendations and exclusive access to local attractions, dining, and custom tours.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed(int currentIndex) {
    if (currentIndex < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeAndNavigate();
    }
  }

  void _completeAndNavigate() async {
    // 1. Mark onboarding as completed in session/preferences
    await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();

    // 2. Navigation hook to Login Screen
    // PLUG_NAVIGATION_HERE: Transitioning from Onboarding -> LoginScreen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = ref.watch(onboardingPageProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Cross-fading Cinematic Background Images
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Image.network(
                _backgroundImages[pageIndex],
                key: ValueKey<int>(pageIndex),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: kBackgroundColor,
                    child: const Center(
                      child: CircularProgressIndicator(color: kPrimaryDimColor),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: kBackgroundColor,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: kNeutralColor),
                  ),
                ),
              ),
            ),
          ),

          // 2. Premium Linear Dark Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                    kBackgroundColor.withOpacity(0.85),
                    kBackgroundColor,
                  ],
                  stops: const [0.0, 0.4, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // 3. Ambient Atmospheric Glow Highlights
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kAccentColor.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryDimColor.withOpacity(0.03),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                child: const SizedBox.shrink(),
              ),
            ),
          ),

          // 4. Header Section: Brand Logo & Skip Button
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sajilo Stay',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: kSecondaryColor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                    ),
                    OnboardingSkipButton(
                      onPressed: _completeAndNavigate,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. Bottom Interactive Bento-Style Glass Card
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bento-inspired Glass Content Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32.0), // radius-[32px]
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: kBackgroundColor.withOpacity(0.65), // glass-card
                            borderRadius: BorderRadius.circular(32.0),
                            border: Border.all(
                              color: kNeutralColor.withOpacity(0.12),
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.all(28.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Progress Pagination Indicators
                              OnboardingDotIndicator(
                                itemCount: _onboardingData.length,
                                currentIndex: pageIndex,
                              ),
                              const SizedBox(height: 32.0),

                              // Swipeable PageView content (Titles and Descriptions)
                              SizedBox(
                                height: 150.0, // Constrained height for text slider
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _onboardingData.length,
                                  onPageChanged: (index) {
                                    ref.read(onboardingPageProvider.notifier).setPage(index);
                                  },
                                  itemBuilder: (context, index) {
                                    return OnboardingPageContent(
                                      title: _onboardingData[index]['title']!,
                                      description: _onboardingData[index]['description']!,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24.0),

                              // Primary Next/Get Started Button
                              OnboardingPrimaryButton(
                                label: pageIndex == _onboardingData.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                icon: pageIndex == _onboardingData.length - 1
                                    ? Icons.check
                                    : Icons.arrow_forward,
                                onPressed: () => _onNextPressed(pageIndex),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Decorative Footer Element
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Premium Global Collections',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: kNeutralColor.withOpacity(0.8),
                                fontSize: 11.0,
                              ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          width: 4.0,
                          height: 4.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kNeutralColor.withOpacity(0.5),
                          ),
                        ),
                        Text(
                          '2026',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: kNeutralColor.withOpacity(0.8),
                                fontSize: 11.0,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sajilo_stay/core/constants/colors.dart';

class OnboardingDotIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const OnboardingDotIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) {
          final isActive = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            height: 6.0,
            width: isActive ? 24.0 : 6.0,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFE3E2E2)
                  : kNeutralColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(9999),
            ),
          );
        },
      ),
    );
  }
}

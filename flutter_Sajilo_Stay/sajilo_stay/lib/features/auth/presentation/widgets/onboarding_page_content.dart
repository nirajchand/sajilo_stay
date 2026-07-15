import 'package:flutter/material.dart';

class OnboardingPageContent extends StatelessWidget {
  final String title;
  final String description;

  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 28.0,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: Color(0xFFE3E2E2), // on-surface
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: Color(0xFFC3C8C3), // on-surface-variant
          ),
        ),
      ],
    );
  }
}

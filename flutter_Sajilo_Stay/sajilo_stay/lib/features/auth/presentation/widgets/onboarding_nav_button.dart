import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sajilo_stay/core/constants/colors.dart';

class OnboardingPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE3E2E2), // on-surface
          foregroundColor: kPrimaryColor, // surface
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // radius-lg/xl
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8.0),
              Icon(icon, size: 20.0, color: kPrimaryColor),
            ],
          ],
        ),
      ),
    );
  }
}

class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OnboardingSkipButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF343535).withOpacity(0.4), // bg-surface-variant/40
            borderRadius: BorderRadius.circular(9999.0),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(9999.0),
              onTap: onPressed,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE3E2E2), // on-surface
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

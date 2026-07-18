import 'package:flutter/material.dart';
import 'package:sajilo_stay/core/constants/colors.dart';

/// A simple scrollable document page (Privacy Policy / Terms & Conditions)
/// with a back button that returns to the previous screen (the profile tab).
class LegalPage extends StatelessWidget {
  final String title;
  final List<LegalSection> sections;

  const LegalPage({super.key, required this.title, required this.sections});

  /// Privacy Policy page.
  factory LegalPage.privacy() => const LegalPage(
        title: 'Privacy Policy',
        sections: [
          LegalSection(
            'Introduction',
            'At Sajilo Stay, your privacy matters to us. This policy explains what '
                'information we collect, how we use it, and the choices you have. By '
                'using the app you agree to the practices described here.',
          ),
          LegalSection(
            'Information We Collect',
            'We collect the details you provide when you create an account (name, '
                'email), your bookings and reviews, and basic device information '
                'needed to keep the app running smoothly and securely.',
          ),
          LegalSection(
            'How We Use Your Information',
            'Your information is used to process bookings and payments, personalise '
                'your experience, respond to support requests, and improve our '
                'services. We never sell your personal data to third parties.',
          ),
          LegalSection(
            'Payments',
            'Payments are processed securely through eSewa. We do not store your '
                'eSewa PIN, full card numbers, or other sensitive payment '
                'credentials on our servers.',
          ),
          LegalSection(
            'Data Security',
            'We use industry-standard safeguards to protect your data. While no '
                'method of transmission is completely secure, we work continuously '
                'to keep your information safe.',
          ),
          LegalSection(
            'Your Choices',
            'You can view and update your profile at any time, and you may request '
                'deletion of your account by contacting our support team.',
          ),
          LegalSection(
            'Contact Us',
            'Questions about this policy? Reach out to us at support@sajilostay.com.',
          ),
        ],
      );

  /// Terms & Conditions page.
  factory LegalPage.terms() => const LegalPage(
        title: 'Terms & Conditions',
        sections: [
          LegalSection(
            'Acceptance of Terms',
            'By creating an account or using Sajilo Stay, you agree to these Terms '
                '& Conditions. If you do not agree, please discontinue use of the '
                'app.',
          ),
          LegalSection(
            'Bookings',
            'All bookings are subject to availability and confirmation. Prices are '
                'shown per night and may change before a booking is confirmed. You '
                'are responsible for providing accurate booking details.',
          ),
          LegalSection(
            'Payments & Refunds',
            'Payments made via eSewa are processed at the time of booking. Refunds '
                'and cancellations are governed by the policy of the individual '
                'property and applicable local regulations.',
          ),
          LegalSection(
            'User Conduct',
            'You agree to use the app lawfully and to provide honest reviews based '
                'on genuine stays. Misuse, fraudulent activity, or abusive content '
                'may result in suspension of your account.',
          ),
          LegalSection(
            'Reviews',
            'Reviews can only be submitted for stays you have completed. We reserve '
                'the right to remove content that violates our guidelines.',
          ),
          LegalSection(
            'Limitation of Liability',
            'Sajilo Stay acts as a platform connecting guests and properties. We '
                'are not liable for the conduct of properties or for events outside '
                'our reasonable control.',
          ),
          LegalSection(
            'Changes to Terms',
            'We may update these terms from time to time. Continued use of the app '
                'after changes constitutes acceptance of the revised terms.',
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kSurfaceLevel1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: kSecondaryColor, size: 16),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kSecondaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final section in sections) ...[
              Text(
                section.heading,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                section.body,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  height: 1.7,
                  color: kNeutralColor,
                ),
              ),
              const SizedBox(height: 22),
            ],
          ],
        ),
      ),
    );
  }
}

class LegalSection {
  final String heading;
  final String body;
  const LegalSection(this.heading, this.body);
}

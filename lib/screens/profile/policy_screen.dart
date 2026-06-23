import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/animations.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  static const String _policyText = '''Privacy Policy

Effective Date: 12 April 2026

Welcome to NSSON Autoparts. Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information when you use our mobile application and services.

1. Information We Collect
We may collect the following types of information:
- Personal Information: Name, phone number, email address, delivery address
- Payment Information: Payments are processed securely via third-party payment gateways. We do not store your debit/credit card or UPI details.
- Device Information: Device type, operating system, IP address, and app usage data

2. How We Use Your Information
We use your information to:
- Process and deliver your orders
- Provide customer support
- Improve our app and services
- Send order updates, notifications, and important alerts

3. Payment Security
All payments are handled through secure and trusted payment gateways. NSSON Autoparts does not store any sensitive payment information such as card details, CVV, or UPI PIN.

4. Data Sharing
We do not sell or rent your personal information. We may share your data only in the following cases:
- With payment gateway providers for processing transactions
- With delivery partners for order fulfillment
- If required by law or legal authorities

5. Data Security
We implement appropriate security measures to protect your data from unauthorized access, misuse, or disclosure.

6. User Rights
You have the right to:
- Access your personal data
- Request correction or deletion of your data
- Contact us regarding any privacy concerns

7. Cookies and Tracking
We may use cookies or similar technologies to enhance user experience and analyze app performance.

8. Changes to This Policy
We may update this Privacy Policy from time to time. Any changes will be reflected with an updated effective date.

9. Contact Us
If you have any questions or concerns about this Privacy Policy, you can contact us:
Email: nssonautoparts@gmail.com
Phone: +91 9778039977''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Privacy Policy & Terms',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: FadeIn(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.policy_outlined,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Privacy Policy',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    _policyText,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

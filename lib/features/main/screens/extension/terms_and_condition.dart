import 'package:flutter/material.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class TermsAndCondition extends StatelessWidget {
  const TermsAndCondition({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: PawsColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: const TermsContent(),
          ),
        ),
      ),
    );
  }
}

/// Reusable terms content for full pages and dialogs.
class TermsContent extends StatelessWidget {
  const TermsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.muted.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.border.withValues(alpha: 0.6),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to PawsConnect',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: PawsColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'A mobile-first platform designed to support adoption, welfare support, and fundraising for Humanity for Animals in Bacoor City, Cavite.',
                    style: TextStyle(
                      fontSize: 14,
                      color: PawsColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'By downloading, accessing, or using our app, you agree to the following Terms and Conditions, which also include our Privacy Policy. Please read carefully before use.',
                    style: TextStyle(
                      fontSize: 14,
                      color: PawsColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const _Section(
              title: '1. User Accounts and Responsibilities',
              bullets: [
                'Users must provide accurate and complete personal information, including name, address, contact number, email, and photos of their home, as required for adoption verification.',
                'Users are responsible for maintaining the confidentiality of their login credentials.',
                'Misuse of the platform, including fraudulent information or unauthorized activity, is prohibited.',
              ],
            ),
            const SizedBox(height: 16),

            const _Section(
              title: '2. Permissions',
              bullets: [
                'The app will automatically enable access to Location services to support adoption logistics and shelter coordination.',
                'PawsConnect will request permission to send Notifications to keep users updated on adoptions, donations, and shelter needs.',
                'Users consent to provide personal information, including home photos, address, email, and contact number, which will be used only for adoption evaluation, communication, and security.',
              ],
            ),
            const SizedBox(height: 16),

            const _Section(
              title: '3. Data Collection and Use',
              bullets: [
                'PawsConnect collects: name, address, email, phone number, location, photos, and adoption-related data.',
                'Data will be used for: adoption processing, password reset via email, communication, notifications, and donation tracking.',
                'Data will not be sold or shared with third parties except trusted partners necessary for platform services (e.g., Supabase, Firebase, Google, payment processors).',
              ],
            ),
            const SizedBox(height: 16),

            const _Section(
              title: '4. Data Retention Policy',
              bullets: [
                'Personal data will be retained only as long as necessary for adoption, donation, or legal requirements.',
                'Adoption records and home verification photos are kept securely for up to 3 years, after which they are deleted unless required for ongoing cases.',
                'Users may request earlier deletion of personal data, subject to applicable laws.',
              ],
            ),
            const SizedBox(height: 16),

            const _Section(
              title: '5. User Rights (GDPR, CCPA, Philippine DPA)',
              intro: 'Users have the right to:',
              bullets: [
                'Access their personal data.',
                'Correct inaccurate or incomplete data.',
                'Request deletion of data (“right to be forgotten”).',
                'Withdraw consent at any time (may affect ability to use adoption features).',
                'File complaints with the National Privacy Commission (Philippines) or relevant authorities.',
              ],
            ),
            const SizedBox(height: 16),

            const _Section(
              title: '6. Children’s Privacy',
              bullets: [
                'PawsConnect is not intended for children under 18 without parental or guardian consent.',
                'We do not knowingly collect personal information from minors. If discovered, such data will be deleted immediately.',
              ],
            ),
            const SizedBox(height: 16),

            const _Section(
              title: '7. Third-Party Services',
              bullets: [
                'The platform integrates third-party services such as Google (authentication, email), Supabase (database), Firebase (notifications), and payment gateways.',
                'Users acknowledge that use of these services is subject to their respective Privacy Policies and Terms.',
              ],
            ),
            const SizedBox(height: 16),

            const _Section(
              title: '8. Community Guidelines',
              bullets: [
                'Users must interact respectfully in forums and volunteer spaces.',
                'Abusive, harmful, or inappropriate behavior will result in account suspension or termination.',
              ],
            ),
            const SizedBox(height: 16),

            const _Section(
              title: '9. Intellectual Property',
              bullets: [
                'All app content, branding, and designs belong to PawsConnect and may not be copied or reused without permission.',
              ],
            ),
            const SizedBox(height: 16),

            const _Section(
              title: '10. Limitation of Liability',
              bullets: [
                'PawsConnect is not responsible for damages arising from misuse, technical issues, or third-party failures.',
                'While reasonable security measures are applied, no system is 100% secure.',
              ],
            ),
            const SizedBox(height: 16),

            const _Section(
              title: '11. Governing Law and Dispute Resolution',
              bullets: [
                'These Terms shall be governed by the laws of the Philippines.',
                'Disputes will be subject to the jurisdiction of the courts in Bacoor City, Cavite.',
                'Alternative resolution methods such as mediation or arbitration may be considered before court proceedings.',
              ],
            ),
            const SizedBox(height: 16),

            const _Section(
              title: '12. Termination',
              bullets: [
                'We may suspend or terminate accounts violating these Terms.',
                'Users may request account deletion at any time.',
              ],
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PawsColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: PawsColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: const Text(
                'By continuing to use PawsConnect, you confirm that you have read, understood, and agreed to these Terms and Conditions and Privacy Policy.',
                style: TextStyle(
                  fontSize: 14,
                  color: PawsColors.textPrimary,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? intro;
  final List<String> bullets;

  const _Section({required this.title, this.intro, required this.bullets});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: PawsColors.textPrimary,
          ),
        ),
        if (intro != null) ...[
          const SizedBox(height: 8),
          Text(
            intro!,
            style: const TextStyle(
              fontSize: 14,
              color: PawsColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 10),
        ...bullets.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: PawsColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    b,
                    style: const TextStyle(
                      fontSize: 14,
                      color: PawsColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

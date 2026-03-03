import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchEmail() async {
    final uri = Uri(scheme: 'mailto', path: 'naz@gmail.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 80, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title ──
                      Text(
                        'About',
                        style: AppTextStyles.displayMedium,
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: constraints.maxHeight * 0.08),

                      // ── About Naz ──
                      Text('About Naz', style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 12),
                      Text(
                        'Naz is a personalized news app built for focused minds.\n\n'
                        'We filter trusted sources into clear, concise updates tailored to your interests.\n\n'
                        'Our mission is simple — remove the noise and surface what truly matters.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        softWrap: true,
                      ),

                      const SizedBox(height: 36),

                      // ── Contact Us ──
                      Text('Contact Us', style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email:  ',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _launchEmail,
                              child: Text(
                                'naz@gmail.com',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Instagram:  ',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'theNaz',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // ── Version ──
                      Center(
                        child: Text(
                          'App Version 1.0.0 © 2026 Naz',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

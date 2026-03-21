import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/nez_card.dart';
import '../data/feed_provider.dart';

/// The Big Picture - Deep Dive Screen
/// Shows comprehensive analysis of a major news story
class BigPictureScreen extends ConsumerStatefulWidget {
  const BigPictureScreen({
    super.key,
    required this.bigPicture,
  });

  final BigPictureData bigPicture;

  @override
  ConsumerState<BigPictureScreen> createState() => _BigPictureScreenState();
}

class _BigPictureScreenState extends ConsumerState<BigPictureScreen> {
  late final PageController _pageController;
  int _currentSection = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.bigPicture.sections;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THE BIG PICTURE',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Deep Dive Analysis',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: List.generate(
                  sections.length,
                  (index) {
                    final isActive = index == _currentSection;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 3,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accent
                              : AppColors.textSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentSection = index);
                },
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  return _SectionPage(
                    section: sections[index],
                    sectionNumber: index + 1,
                    totalSections: sections.length,
                    isLast: index == sections.length - 1,
                    onNext: () {
                      if (index < sections.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual section page within the Big Picture
class _SectionPage extends StatelessWidget {
  const _SectionPage({
    required this.section,
    required this.sectionNumber,
    required this.totalSections,
    required this.isLast,
    required this.onNext,
  });

  final BigPictureSection section;
  final int sectionNumber;
  final int totalSections;
  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Section number and title
          Text(
            '0$sectionNumber',
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            section.title,
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: 28,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 24),

          // Content
          ...section.content.map((block) {
            if (block is TextBlock) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  block.text,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 16,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            } else if (block is BulletListBlock) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: block.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            } else if (block is StatBlock) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: NezCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        block.stat,
                        style: AppTextStyles.displayMedium.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        block.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (block is QuoteBlock) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border(
                      left: BorderSide(
                        color: AppColors.accent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${block.quote}"',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                      if (block.author != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          '— ${block.author}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 16),

          // Navigation button
          if (!isLast)
            GestureDetector(
              onTap: onNext,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue Reading',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.background,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.background,
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(
                  color: AppColors.border,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'You\'ve completed this deep dive',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

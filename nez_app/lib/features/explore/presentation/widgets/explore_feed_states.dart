import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ExploreCaughtUpBanner extends StatelessWidget {
  const ExploreCaughtUpBanner({required this.visible, super.key});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: visible
          ? Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You\'re all caught up!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class ExploreProgressRail extends StatelessWidget {
  const ExploreProgressRail({
    required this.itemCount,
    required this.currentIndex,
    this.width = 24,
    super.key,
  });

  final int itemCount;
  final int currentIndex;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(itemCount > 12 ? 12 : itemCount, (index) {
            final isActive =
                index == currentIndex || (index == 11 && currentIndex >= 11);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 3),
              width: 6,
              height: isActive ? 22 : 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class ExploreEmptyFeedState extends StatelessWidget {
  const ExploreEmptyFeedState({
    required this.category,
    required this.onBrowseAll,
    super.key,
  });

  final String category;
  final VoidCallback onBrowseAll;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.newspaper_rounded,
                  size: 56,
                  color: AppColors.textSecondary.withValues(alpha: 0.35),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nothing in $category yet',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pull down to refresh, or browse all news below.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: onBrowseAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Browse All News',
                      style: AppTextStyles.labelMedium.copyWith(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

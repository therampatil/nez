import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/feed_provider.dart';
import 'headline_card.dart';

class DailyTwelveSection extends StatelessWidget {
  const DailyTwelveSection({
    required this.headlinesAsync,
    required this.pageController,
    required this.currentPage,
    required this.onRetry,
    super.key,
  });

  final AsyncValue<List<ApiArticle>> headlinesAsync;
  final PageController pageController;
  final int currentPage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DailyTwelveHeader(),
        const SizedBox(height: 24),

        headlinesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(
                color: AppColors.textPrimary,
                strokeWidth: 2,
              ),
            ),
          ),

          error: (_, _) => _DailyTwelveError(onRetry: onRetry),

          data: (articles) {
            final top12 = articles.take(12).toList();
            if (top12.isEmpty) return const _DailyTwelveEmptyState();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔥 CARD CAROUSEL
                SizedBox(
                  height: 640,
                  child: PageView.builder(
                    controller: pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: top12.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: pageController,
                        builder: (context, child) {
                          double value = 1.0;

                          if (pageController.position.haveDimensions) {
                            value = (pageController.page ?? 0) - index;
                            value =
                                (1 - (value.abs() * 0.12)).clamp(0.88, 1.0);
                          }

                          return Center(
                            child: FractionallySizedBox(
                              widthFactor: 1.1,
                              child: Transform.scale(
                                scale: value,
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              ),
                            ),
                          );
                        },
                        child: HeadlineCard(
                          article: top12[index],
                          index: index,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                /// 🔥 FIXED INDICATOR (NO OVERFLOW, PERFECT ALIGNMENT)
                LayoutBuilder(
                  builder: (context, constraints) {
                    const dotSize = 8.0;
                    const spacing = 8.0;
                    const activeWidth = 28.0;

                    final totalWidth = top12.length * dotSize +
                        (top12.length - 1) * spacing;

                    final startX =
                        (constraints.maxWidth - totalWidth) / 2;

                    final step = dotSize + spacing;

                    final activeX = startX + (currentPage * step);

                    return SizedBox(
                      height: 10,
                      child: Stack(
                        children: [
                          /// background dots
                          Positioned(
                            left: startX,
                            child: Row(
                              children: List.generate(top12.length, (_) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  width: dotSize,
                                  height: dotSize,
                                  decoration: BoxDecoration(
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.2),
                                    borderRadius:
                                        BorderRadius.circular(999),
                                  ),
                                );
                              }),
                            ),
                          ),

                          /// active sliding bar
                          AnimatedPositioned(
                            duration:
                                const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            left: activeX,
                            child: Container(
                              width: activeWidth,
                              height: dotSize,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(999),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.textPrimary,
                                    AppColors.accent
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DailyTwelveHeader extends StatelessWidget {
  const _DailyTwelveHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The Daily 12',
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.4,
              height: 1,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            width: 72,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.textPrimary],
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DailyTwelveError extends StatelessWidget {
  const _DailyTwelveError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: AppColors.borderLight, width: 1.4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Failed to load headlines',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Pull again to refresh or retry the headlines request.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Retry',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyTwelveEmptyState extends StatelessWidget {
  const _DailyTwelveEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: AppColors.border, width: 1.4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.newspaper_rounded,
                size: 64,
                color: AppColors.textSecondary
                    .withValues(alpha: 0.3),
              ),
              const SizedBox(height: 18),
              Text(
                'No headlines yet',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

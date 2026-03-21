import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/nez_card.dart';
import '../../../onboarding/data/preferences_provider.dart';
import '../../data/personalized_insight.dart';
import '../../data/personalized_insights_service.dart';

final personalizedInsightsServiceProvider =
    Provider<PersonalizedInsightsService>(
      (ref) => PersonalizedInsightsService(),
    );

class ForYouInsightsSection extends ConsumerWidget {
  const ForYouInsightsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(preferencesProvider).valueOrNull ?? [];
    final insights = ref
        .read(personalizedInsightsServiceProvider)
        .buildInsights(userPreferences);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'CURATED FOR YOU',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'For You',
          style: AppTextStyles.displayMedium.copyWith(
            fontSize: 31,
            fontWeight: FontWeight.w900,
            height: 1.04,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Focused prompts, opportunity signals, and context tuned to what you care about.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        ...insights.asMap().entries.map((entry) {
          final index = entry.key;
          final insight = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index == insights.length - 1 ? 0 : 14),
            child: _InsightCard(insight: insight, index: index),
          );
        }),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight, required this.index});

  final PersonalizedInsight insight;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${insight.actionLabel} - Coming soon!',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [
              AppColors.card,
              AppColors.card.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.borderLight, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowStrong,
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: NezCard(
          padding: const EdgeInsets.all(0),
          color: Colors.transparent,
          shadow: false,
          border: Border.all(color: Colors.transparent),
          borderRadius: 30,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.9),
                            AppColors.accentHover,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(insight.icon, size: 22, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(index + 1).toString().padLeft(2, '0')} · ${insight.category.toUpperCase()}',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 10,
                              letterSpacing: 1.25,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            insight.title,
                            style: AppTextStyles.headlineMedium.copyWith(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: Text(
                    insight.insight,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      height: 1.55,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.borderLight, width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          insight.actionLabel,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_outward_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                      ],
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

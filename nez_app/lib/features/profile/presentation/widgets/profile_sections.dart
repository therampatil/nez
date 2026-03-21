import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ProfileStreakMiniCard extends StatelessWidget {
  const ProfileStreakMiniCard({required this.data, super.key});

  final dynamic data;

  @override
  Widget build(BuildContext context) {
    final streak = data.currentStreak as int;
    final total = data.totalArticlesRead as int;
    final longest = data.longestStreak as int;

    String streakMsg;
    if (streak == 0) {
      streakMsg = 'No active streak - open an article to start one!';
    } else if (streak < 3) {
      streakMsg = 'Great start! Keep reading daily to build your streak.';
    } else if (streak < 7) {
      streakMsg = 'You\'re on a roll! $streak days and counting.';
    } else {
      streakMsg = 'Incredible! $streak-day streak - you\'re unstoppable.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF000000),
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$streak',
                style: AppTextStyles.headlineLarge.copyWith(fontSize: 48),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'day streak',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            streakMsg,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(label: 'Articles Read', value: '$total'),
              Container(
                width: 1,
                height: 32,
                color: AppColors.divider,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _MiniStat(label: 'Longest Streak', value: '$longest days'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class ProfilePreferenceChip extends StatelessWidget {
  const ProfilePreferenceChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.chipSelected,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }
}

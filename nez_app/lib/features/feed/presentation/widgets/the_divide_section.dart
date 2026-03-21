import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/nez_card.dart';

class TheDivideSection extends StatelessWidget {
  const TheDivideSection({
    required this.userVote,
    required this.forVotes,
    required this.againstVotes,
    required this.onVote,
    super.key,
  });

  final String? userVote;
  final int forVotes;
  final int againstVotes;
  final ValueChanged<String> onVote;

  @override
  Widget build(BuildContext context) {
    final totalVotes = forVotes + againstVotes;
    final forPercentage = totalVotes > 0
        ? (forVotes / totalVotes * 100).round()
        : 50;
    final againstPercentage = 100 - forPercentage;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            AppColors.card,
            AppColors.card.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.borderLight, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: NezCard(
        padding: const EdgeInsets.all(0),
        color: Colors.transparent,
        shadow: false,
        border: Border.all(color: Colors.transparent),
        borderRadius: 32,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Text(
                          'THE DIVIDE',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 11,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(totalVotes / 1000).toStringAsFixed(1)}k votes',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aadhaar-linked SIM cards split the country',
                    style: AppTextStyles.displayMedium.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.06,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'National security and digital rights collide in one of the biggest identity-policy debates of the year.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _InfoChip(label: 'Policy'),
                      _InfoChip(label: 'Privacy'),
                      _InfoChip(label: '1.4B affected'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border, width: 1.3),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Live pulse',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          'Updated today',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        height: 10,
                        child: Row(
                          children: [
                            Expanded(
                              flex: forPercentage,
                              child: Container(color: AppColors.textPrimary),
                            ),
                            Expanded(
                              flex: againstPercentage,
                              child: Container(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 520;
                  if (stacked) {
                    return Column(
                      children: [
                        _VoteSide(
                          label: 'FOR IT',
                          description:
                              'Prevents SIM fraud and strengthens national-security enforcement.',
                          percentage: forPercentage,
                          isSelected: userVote == 'for',
                          accentColor: AppColors.textPrimary,
                          onTap: () => onVote('for'),
                        ),
                        const SizedBox(height: 12),
                        _VoteSide(
                          label: 'AGAINST',
                          description:
                              'Creates a surveillance precedent and weakens personal privacy.',
                          percentage: againstPercentage,
                          isSelected: userVote == 'against',
                          accentColor: AppColors.accent,
                          onTap: () => onVote('against'),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: _VoteSide(
                          label: 'FOR IT',
                          description:
                              'Prevents SIM fraud and strengthens national-security enforcement.',
                          percentage: forPercentage,
                          isSelected: userVote == 'for',
                          accentColor: AppColors.textPrimary,
                          onTap: () => onVote('for'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _VoteSide(
                          label: 'AGAINST',
                          description:
                              'Creates a surveillance precedent and weakens personal privacy.',
                          percentage: againstPercentage,
                          isSelected: userVote == 'against',
                          accentColor: AppColors.accent,
                          onTap: () => onVote('against'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      userVote == null
                          ? 'Pick a side to see where the crowd is leaning.'
                          : 'Your vote is in. Keep watching how the split shifts.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: userVote == null
                          ? AppColors.background
                          : AppColors.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: userVote == null
                            ? AppColors.border
                            : AppColors.accent.withValues(alpha: 0.26),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          userVote == null
                              ? Icons.touch_app_rounded
                              : Icons.check_circle_rounded,
                          size: 16,
                          color: userVote == null
                              ? AppColors.textPrimary
                              : AppColors.accent,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          userVote == null ? 'Tap to vote' : 'Vote recorded',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: userVote == null
                                ? AppColors.textPrimary
                                : AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteSide extends StatelessWidget {
  const _VoteSide({
    required this.label,
    required this.description,
    required this.percentage,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final String description;
  final int percentage;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: accentColor == AppColors.accent ? 0.12 : 0.08)
              : AppColors.background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.border,
            width: isSelected ? 1.6 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '$percentage%',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: accentColor,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

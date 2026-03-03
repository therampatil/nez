import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A horizontal step-progress indicator used across the onboarding flow.
///
/// Shows [totalSteps] segments; segments up to and including [currentStep]
/// are filled; remaining segments are dimmed.
///
/// Usage:
///   OnboardingProgress(currentStep: 1, totalSteps: 2)  // Signup screen
///   OnboardingProgress(currentStep: 2, totalSteps: 2)  // Preferences screen
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  /// 1-based index of the current step (1 = first step).
  final int currentStep;

  /// Total number of steps in the onboarding flow.
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps * 2 - 1, (i) {
        // Odd indices are the gaps between segments
        if (i.isOdd) return const SizedBox(width: 6);

        final stepIndex = i ~/ 2; // 0-based
        final isCompleted = stepIndex < currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 52,
          height: 4,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.textPrimary
                : AppColors.textSecondary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

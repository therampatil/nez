import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/design_constants.dart';

enum NezButtonVariant { filled, outlined, text }

/// Button component — three variants, matches mockup style.
class NezButton extends StatelessWidget {
  const NezButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NezButtonVariant.filled,
    this.isLoading = false,
    this.isExpanded = true,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final NezButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;

  /// When true (filled variant only) uses the error / destructive colour.
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accentText,
            ),
          )
        : Text(label, style: _labelStyle);

    switch (variant) {
      case NezButtonVariant.filled:
        return SizedBox(
          width: isExpanded ? double.infinity : null,
          height: DesignConstants.buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? AppColors.error
                  : AppColors.accent,
              foregroundColor: AppColors.accentText,
              disabledBackgroundColor: AppColors.disabled,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: child,
          ),
        );

      case NezButtonVariant.outlined:
        return SizedBox(
          width: isExpanded ? double.infinity : null,
          height: DesignConstants.buttonHeight,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );

      case NezButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
    }
  }

  TextStyle get _labelStyle {
    switch (variant) {
      case NezButtonVariant.filled:
        return AppTextStyles.labelLarge.copyWith(color: AppColors.accentText);
      case NezButtonVariant.outlined:
        return AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary);
      case NezButtonVariant.text:
        return AppTextStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
        );
    }
  }
}

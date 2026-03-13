import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Enhanced card with subtle shadows and rounded corners
class NezCard extends StatelessWidget {
  const NezCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.border,
    this.shadow = true,
    this.borderRadius = 24.0,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final VoidCallback? onTap;
  final bool shadow;
  final Border? border;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: color ?? AppColors.card,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(color: AppColors.border, width: 1),
          boxShadow: shadow ? AppShadows.card : null,
        ),
        child: child,
      ),
    );
  }
}

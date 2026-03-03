import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// White card with hard black drop-shadow — the signature Nez depth effect.
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
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final VoidCallback? onTap;
  final bool shadow;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        clipBehavior: Clip.none,
        decoration: BoxDecoration(
          color: color ?? AppColors.card,
          borderRadius: BorderRadius.zero,
          border: border ?? Border.all(color: AppColors.border, width: 1.5),
          boxShadow: shadow ? AppShadows.card : null,
        ),
        child: child,
      ),
    );
  }
}

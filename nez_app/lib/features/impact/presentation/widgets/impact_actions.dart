import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ImpactIconButton extends StatelessWidget {
  const ImpactIconButton({
    required this.assetPath,
    required this.onTap,
    super.key,
  });

  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 18,
            height: 18,
            color: AppColors.textPrimary,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class ImpactBookmarkButton extends StatelessWidget {
  const ImpactBookmarkButton({
    required this.isBookmarked,
    required this.onTap,
    super.key,
  });

  final bool isBookmarked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isBookmarked ? AppColors.textPrimary : Colors.transparent,
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/bookmark.png',
            width: 18,
            height: 18,
            color: isBookmarked ? Colors.white : AppColors.textPrimary,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class FollowNewsButton extends StatelessWidget {
  const FollowNewsButton({
    required this.onTap,
    required this.isFollowing,
    super.key,
  });

  final VoidCallback onTap;
  final bool isFollowing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isFollowing ? AppColors.accent : Colors.transparent,
          border: Border.all(
            color: isFollowing ? AppColors.accent : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFollowing ? Icons.check_rounded : Icons.add_rounded,
              size: 16,
              color: isFollowing ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              isFollowing ? 'Following' : 'Follow News',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                color: isFollowing ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

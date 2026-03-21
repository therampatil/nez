import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Bottom navigation bar matching the mockup — dark pill-shaped bar with icons.
/// Navigation: 0=Home, 1=Followed, 2=Explore, 3=Profile
class NezBottomNav extends StatelessWidget {
  const NezBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.followedNewsUnreadCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int followedNewsUnreadCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(60, 0, 60, 16),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowMedium,
                offset: Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                assetPath: 'assets/images/home.png',
                index: 0,
                currentIndex: currentIndex,
                onTap: () => onTap(0),
              ),
              _NavItem(
                assetPath: 'assets/images/megaphone.png',
                index: 1,
                currentIndex: currentIndex,
                onTap: () => onTap(1),
              ),
              _NavItem(
                assetPath: 'assets/images/flowchart.png',
                index: 2,
                currentIndex: currentIndex,
                onTap: () => onTap(2),
                unreadCount: followedNewsUnreadCount,
              ),
              _NavItem(
                assetPath: 'assets/images/user.png',
                index: 3,
                currentIndex: currentIndex,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.assetPath,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.unreadCount = 0,
  });

  final String assetPath;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  assetPath,
                  width: 26,
                  height: 26,
                  color: Colors.white,
                  fit: BoxFit.contain,
                  opacity: AlwaysStoppedAnimation(isSelected ? 1.0 : 0.5),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 2,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.textPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
            // Unread badge
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.card, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                  child: unreadCount > 9 ? null : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

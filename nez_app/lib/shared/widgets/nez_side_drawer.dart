import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Side drawer — vertical dark pill with icons, always visible on profile tab.
/// [currentIndex] maps to: 0=Profile, 1=Saved, 2=Settings, 3=Help, 4=About
/// [onTap] fires with the tapped index.
class NezSideDrawer extends StatelessWidget {
  const NezSideDrawer({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.onLogout,
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: AppShadows.elevated,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DrawerIcon(
                assetPath: 'assets/images/user (2).png',
                isActive: currentIndex == 0,
                onTap: () => onTap?.call(0),
              ),
              const SizedBox(height: 24),
              _DrawerIcon(
                assetPath: 'assets/images/bookmark.png',
                isActive: currentIndex == 1,
                onTap: () => onTap?.call(1),
              ),
              const SizedBox(height: 24),
              _DrawerIcon(
                assetPath: 'assets/images/setting (1).png',
                isActive: currentIndex == 2,
                onTap: () => onTap?.call(2),
              ),
              const SizedBox(height: 24),
              _DrawerIcon(
                assetPath: 'assets/images/help-web-button.png',
                isActive: currentIndex == 3,
                onTap: () => onTap?.call(3),
              ),
              const SizedBox(height: 24),
              _DrawerIcon(
                assetPath: 'assets/images/information-button.png',
                isActive: currentIndex == 4,
                onTap: () => onTap?.call(4),
              ),
              const SizedBox(height: 24),
              _DrawerIcon(icon: Icons.logout, isActive: false, onTap: onLogout),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerIcon extends StatelessWidget {
  const _DrawerIcon({
    this.assetPath,
    this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final String? assetPath;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: assetPath != null
              ? Image.asset(
                  assetPath!,
                  width: 22,
                  height: 22,
                  color: isActive ? AppColors.accent : AppColors.textTertiary,
                  fit: BoxFit.contain,
                )
              : Icon(
                  icon,
                  color: isActive ? AppColors.accent : AppColors.textTertiary,
                  size: 22,
                ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/search/presentation/search_screen.dart';

class NezTopBar extends StatelessWidget {
  const NezTopBar({
    this.padding = const EdgeInsets.fromLTRB(24, 20, 24, 16),
    this.showNotificationBadge = false,
    super.key,
  });

  final EdgeInsets padding;
  final bool showNotificationBadge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/nez_logo.png',
            height: 36,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            child: Image.asset(
              'assets/images/search.png',
              width: 24,
              height: 24,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 32,
              height: 32,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Center(
                      child: Image.asset(
                        'assets/images/notification.png',
                        width: 24,
                        height: 24,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (showNotificationBadge)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

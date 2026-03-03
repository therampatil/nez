import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/nez_card.dart';
import '../../feed/data/article_model.dart';
import '../../feed/data/feed_provider.dart';
import '../../impact/presentation/impact_screen.dart';
import '../data/notification_model.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back / close icon
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(
                            Icons.arrow_back,
                            size: 22,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notifications',
                          style: AppTextStyles.headlineLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Unread badge
                      if (unread > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$unread new',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      // Mark all read
                      if (unread > 0)
                        GestureDetector(
                          onTap: () => ref
                              .read(notificationsProvider.notifier)
                              .markAllRead(),
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            'Mark all read',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Notification list ──
                Expanded(
                  child: notifications.isEmpty
                      ? _EmptyState(constraints: constraints)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                          physics: const BouncingScrollPhysics(),
                          itemCount: notifications.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = notifications[index];
                            return _NotificationCard(
                              item: item,
                              onTap: () {
                                ref
                                    .read(notificationsProvider.notifier)
                                    .markRead(item.id);
                                if (item.articleIndex != null) {
                                  final local = allArticles[item.articleIndex!];
                                  final article = ApiArticle.fromArticle(
                                    local,
                                    id: item.articleIndex!,
                                  );
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ImpactScreen(
                                        article: article,
                                        articleIndex: item.articleIndex!,
                                      ),
                                    ),
                                  );
                                }
                              },
                              onDelete: () => ref
                                  .read(notificationsProvider.notifier)
                                  .delete(item.id),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// NOTIFICATION CARD
// Inline × button deletes the notification.
// Tapping the card opens the linked article (if any).
// ──────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final NezNotification item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isNewsLinked = item.articleIndex != null;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GestureDetector(
          onTap: onTap,
          child: NezCard(
            padding: const EdgeInsets.all(16),
            color: item.isRead ? AppColors.card : const Color(0xFFF5F5F5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Icon container ──
                _NotificationIcon(type: item.type, isRead: item.isRead),

                const SizedBox(width: 14),

                // ── Content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row + unread dot
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: item.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(left: 8, top: 2),
                              decoration: const BoxDecoration(
                                color: AppColors.textPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // Body text
                      Text(
                        item.body,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: item.isRead
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          height: 1.45,
                        ),
                        softWrap: true,
                      ),

                      const SizedBox(height: 10),

                      // Footer: source + time + optional "Read story →"
                      Row(
                        children: [
                          if (item.sourceName != null) ...[
                            Text(
                              item.sourceName!,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                '·',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textHint,
                                ),
                              ),
                            ),
                          ],
                          Text(
                            item.timeAgo,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textHint,
                              fontSize: 11,
                            ),
                          ),
                          if (isNewsLinked) ...[
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Read story',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 11,
                                  color: AppColors.textPrimary,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // ── × Delete button ──
                GestureDetector(
                  onTap: onDelete,
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// NOTIFICATION ICON
// ──────────────────────────────────────────────
class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type, required this.isRead});

  final NotificationType type;
  final bool isRead;

  String get _assetPath {
    switch (type) {
      case NotificationType.ai:
        return 'assets/images/ai.png';
      case NotificationType.finance:
        return 'assets/images/rupee-indian.png';
      default:
        return 'assets/images/notification.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isRead ? AppColors.background : AppColors.textPrimary,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.zero,
      ),
      child: Center(
        child: Image.asset(
          _assetPath,
          width: 22,
          height: 22,
          color: isRead ? AppColors.textPrimary : Colors.white,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// EMPTY STATE
// ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.constraints});

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 80),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/notification.png',
                width: 56,
                height: 56,
                color: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 20),
              Text('All Caught Up', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'No new notifications right now.\nCheck back later.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

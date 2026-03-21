import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/followed_stories_provider.dart';
import '../../../../core/theme/app_theme.dart';

class FollowedNewsHeader extends StatelessWidget {
  const FollowedNewsHeader({
    required this.totalUnread,
    required this.followedStoriesAsync,
    super.key,
  });

  final int totalUnread;
  final AsyncValue<List<FollowedStory>> followedStoriesAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                'Following',
                style: AppTextStyles.displayMedium.copyWith(fontSize: 32),
              ),
              if (totalUnread > 0) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalUnread new',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: followedStoriesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (stories) => Text(
              '${stories.length} ${stories.length == 1 ? 'story' : 'stories'} tracked · $totalUnread new ${totalUnread == 1 ? 'update' : 'updates'}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum FollowedNewsViewMode { following, updates }

class FollowedNewsViewSwitcher extends StatelessWidget {
  const FollowedNewsViewSwitcher({
    required this.mode,
    required this.onModeChanged,
    super.key,
  });

  final FollowedNewsViewMode mode;
  final ValueChanged<FollowedNewsViewMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Row(
          children: [
            Expanded(
              child: _SwitcherButton(
                label: 'Following',
                isActive: mode == FollowedNewsViewMode.following,
                onTap: () => onModeChanged(FollowedNewsViewMode.following),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _SwitcherButton(
                label: 'Updates',
                isActive: mode == FollowedNewsViewMode.updates,
                onTap: () => onModeChanged(FollowedNewsViewMode.updates),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitcherButton extends StatelessWidget {
  const _SwitcherButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isActive ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class FollowedNewsErrorState extends StatelessWidget {
  const FollowedNewsErrorState({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Failed to load followed news',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Retry',
                style: AppTextStyles.labelMedium.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FollowedNewsEmptyState extends StatelessWidget {
  const FollowedNewsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bookmarks_outlined,
                  size: 56,
                  color: AppColors.textSecondary.withValues(alpha: 0.35),
                ),
                const SizedBox(height: 20),
                Text(
                  'No followed stories yet',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap "Follow News" on any article to track updates about that story. You\'ll see all updates here.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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

class FollowedNewsNoUpdatesState extends StatelessWidget {
  const FollowedNewsNoUpdatesState({required this.trackedStories, super.key});

  final int trackedStories;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.update_rounded,
                  size: 56,
                  color: AppColors.textSecondary.withValues(alpha: 0.35),
                ),
                const SizedBox(height: 20),
                Text(
                  'No new updates yet',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$trackedStories ${trackedStories == 1 ? 'story is' : 'stories are'} being tracked. New developments will appear here automatically.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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

class FollowedStoriesListState extends StatelessWidget {
  const FollowedStoriesListState({
    required this.stories,
    required this.onRefresh,
    super.key,
  });

  final List<FollowedStory> stories;
  final Future<void> Function() onRefresh;

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final mm = local.month.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    return '$mm/$dd/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const FollowedNewsEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.textPrimary,
      backgroundColor: AppColors.card,
      strokeWidth: 2,
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        itemCount: stories.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final story = stories[index];
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        story.storyTitle,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (story.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${story.unreadCount} new',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${story.updates.length} ${story.updates.length == 1 ? 'update' : 'updates'} · Tracking since ${_formatDate(story.createdAt)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FollowedNewsProgressRail extends StatelessWidget {
  const FollowedNewsProgressRail({
    required this.articlesLength,
    required this.currentArticleIndex,
    super.key,
  });

  final int articlesLength;
  final int currentArticleIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            articlesLength > 12 ? 12 : articlesLength,
            (i) {
              final isActive =
                  i == currentArticleIndex || (i == 11 && currentArticleIndex >= 11);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(vertical: 3),
                width: 6,
                height: isActive ? 22 : 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class FollowedNewsCaughtUpBanner extends StatelessWidget {
  const FollowedNewsCaughtUpBanner({required this.visible, super.key});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: visible
          ? Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You\'re all caught up!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

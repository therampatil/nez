import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/bookmarks_provider.dart';
import '../../../shared/widgets/nez_card.dart';
import '../../feed/data/feed_provider.dart';
import '../../impact/presentation/impact_screen.dart';
import '../../search/presentation/search_screen.dart';

// Horizontal offset so content clears the vertical side drawer (width 52 + left 12 = 64).
const double _kDrawerOffset = 68.0;

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedIds = ref.watch(bookmarksProvider);
    final feedAsync = ref.watch(feedProvider);

    final saved =
        feedAsync.valueOrNull
            ?.where((a) => bookmarkedIds.contains(a.id))
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // ── Empty state ──
            if (saved.isEmpty) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: _kDrawerOffset, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Bookmarks', style: AppTextStyles.displayMedium),
                        SizedBox(height: constraints.maxHeight * 0.22),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bookmark_outline_rounded,
                                size: 64,
                                color: AppColors.textSecondary.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Bookmarks Yet',
                                style: AppTextStyles.headlineLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the bookmark icon on any\narticle to save it here.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // ── Filled state ──
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(_kDrawerOffset, 24, 24, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text('Bookmarks', style: AppTextStyles.displayMedium),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              color: AppColors.textPrimary,
                              child: Text(
                                '${saved.length}',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Search icon
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        ),
                        child: Image.asset(
                          'assets/images/search.png',
                          width: 22,
                          height: 22,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: _kDrawerOffset,
                      right: 24,
                      bottom: 32,
                    ),
                    itemCount: saved.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      final article = saved[i];
                      return _BookmarkedCard(
                        article: article,
                        articleIndex: i,
                        onRemove: () =>
                            ref.read(bookmarksProvider.notifier).toggle(article.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ImpactScreen(
                              article: article,
                              articleIndex: i,
                            ),
                          ),
                        ),
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
// BOOKMARKED CARD
// ──────────────────────────────────────────────
class _BookmarkedCard extends StatelessWidget {
  const _BookmarkedCard({
    required this.article,
    required this.articleIndex,
    required this.onRemove,
    required this.onTap,
  });

  final ApiArticle article;
  final int articleIndex;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NezCard(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Category chip ──
            if (article.category != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Text(
                  article.category!.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // ── Headline with left accent bar ──
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 3.5, color: AppColors.textPrimary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      article.title,
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: 24,
                        height: 1.15,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Time + Source ──
            Row(
              children: [
                Text(
                  article.timeAgo,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Text(
                    article.source ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Action row ──
            Row(
              children: [
                // Share
                _IconButton(
                  assetPath: 'assets/images/share.png',
                  onTap: () {
                    final text = '${article.title}\n\nRead on Nez: nez://article/${article.id}';
                    Share.share(text, subject: article.title);
                  },
                ),
                const SizedBox(width: 8),
                // Remove bookmark
                GestureDetector(
                  onTap: onRemove,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/bookmark.png',
                        width: 18,
                        height: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // See the Impact →
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      border: Border.all(color: AppColors.textPrimary, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See the Impact',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// GENERIC ICON BUTTON
// ──────────────────────────────────────────────
class _IconButton extends StatelessWidget {
  const _IconButton({required this.assetPath, required this.onTap});

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
          ),
        ),
      ),
    );
  }
}

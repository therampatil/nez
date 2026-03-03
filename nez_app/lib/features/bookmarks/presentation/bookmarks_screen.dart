import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/bookmarks_provider.dart';
import '../../../shared/widgets/nez_card.dart';
import '../../feed/data/feed_provider.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedIds = ref.watch(bookmarksProvider);
    final feedAsync = ref.watch(feedProvider);

    // Filter live feed articles by bookmarked IDs
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
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bookmarks',
                              style: AppTextStyles.displayMedium,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.25),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bookmark_outline_rounded,
                                    size: 64,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.4,
                                    ),
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
                  ),
                ),
              );
            }

            // ── Filled state ──
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
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
                Expanded(
                  child: ListView.separated(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    itemCount: saved.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, i) {
                      final article = saved[i];
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: _BookmarkedCard(
                            article: article,
                            onRemove: () => ref
                                .read(bookmarksProvider.notifier)
                                .toggle(article.id),
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
  const _BookmarkedCard({required this.article, required this.onRemove});

  final ApiArticle article;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return NezCard(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
                      fontSize: 26,
                      height: 1.15,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Time + Source ──
          Row(
            children: [
              Text(
                article.timeAgo,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  'Source - ${article.source ?? ''}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Action row ──
          Row(
            children: [
              _IconButton(assetPath: 'assets/images/share.png', onTap: () {}),
              const SizedBox(width: 8),
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
            ],
          ),
        ],
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

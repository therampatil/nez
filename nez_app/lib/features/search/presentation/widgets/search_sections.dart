import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/bookmarks_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../feed/data/feed_provider.dart';
import '../../../impact/presentation/impact_screen.dart';

class SearchBarSection extends StatelessWidget {
  const SearchBarSection({
    required this.controller,
    required this.focusNode,
    required this.onClear,
    required this.onBack,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 36,
              height: 44,
              child: Center(
                child: Icon(
                  Icons.arrow_back,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    offset: Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Image.asset(
                    'assets/images/search.png',
                    width: 18,
                    height: 18,
                    color: AppColors.textSecondary,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search news, topics, sources...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textInputAction: TextInputAction.search,
                      cursorColor: AppColors.textPrimary,
                      cursorWidth: 1.5,
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, child) {
                      if (value.text.isEmpty) {
                        return const SizedBox(width: 12);
                      }
                      return GestureDetector(
                        onTap: onClear,
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
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

class SearchIdleBody extends StatelessWidget {
  const SearchIdleBody({
    required this.recents,
    required this.trendingTopics,
    required this.onRecentTap,
    required this.onClearRecent,
    required this.onClearAll,
    required this.onTopicTap,
    super.key,
  });

  final List<String> recents;
  final List<String> trendingTopics;
  final ValueChanged<String> onRecentTap;
  final ValueChanged<String> onClearRecent;
  final VoidCallback onClearAll;
  final ValueChanged<String> onTopicTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recents.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                ),
                GestureDetector(
                  onTap: onClearAll,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'Clear all',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recents.map(
              (recent) => _RecentTile(
                text: recent,
                onTap: () => onRecentTap(recent),
                onDismiss: () => onClearRecent(recent),
              ),
            ),
            const SizedBox(height: 28),
          ],
          Text(
            'Trending Topics',
            style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: trendingTopics.map((topic) {
              return _TopicChip(label: topic, onTap: () => onTopicTap(topic));
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SearchResultsBody extends StatelessWidget {
  const SearchResultsBody({
    required this.query,
    required this.results,
    required this.bookmarked,
    required this.ref,
    super.key,
  });

  final String query;
  final List<ApiArticle> results;
  final Set<int> bookmarked;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return SearchEmptyResults(query: query);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final article = results[index];
        return _SearchResultCard(
          article: article,
          isBookmarked: bookmarked.contains(article.id),
          onBookmarkTap: () =>
              ref.read(bookmarkedArticlesProvider.notifier).toggle(article),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ImpactScreen(
                  article: article,
                  articleIndex: index,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.article,
    required this.isBookmarked,
    required this.onBookmarkTap,
    required this.onTap,
  });

  final ApiArticle article;
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowMedium,
              offset: Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 3.5, height: 56, color: AppColors.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.category != null && article.category!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '#${article.category}',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    article.title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        article.timeAgo,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          article.source ?? '',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onBookmarkTap,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isBookmarked
                      ? AppColors.accent
                      : Colors.transparent,
                  border: Border.all(color: AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/bookmark.png',
                    width: 16,
                    height: 16,
                    color: isBookmarked ? Colors.white : AppColors.textPrimary,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({
    required this.text,
    required this.onTap,
    required this.onDismiss,
  });

  final String text;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Image.asset(
              'assets/images/clock.png',
              width: 16,
              height: 16,
              color: AppColors.textSecondary,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(Icons.close, size: 16, color: AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class SearchEmptyResults extends StatelessWidget {
  const SearchEmptyResults({required this.query, super.key});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/search.png',
              width: 52,
              height: 52,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              'No results for',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '"$query"',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              'Try a different keyword or browse\ntrending topics below.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

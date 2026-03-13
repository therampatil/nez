import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/bookmarks_provider.dart';
import '../../feed/data/article_model.dart';
import '../../feed/data/feed_provider.dart';
import '../../impact/presentation/impact_screen.dart';

// ──────────────────────────────────────────────
// TRENDING TOPICS
// ──────────────────────────────────────────────
const _trendingTopics = [
  'AI Policy',
  'RBI',
  'Budget 2026',
  'Supreme Court',
  'Climate',
  'Education',
  'Digital Privacy',
  'Finance',
  'Technology',
  'Global',
  'Laws',
  'Society',
];

// ──────────────────────────────────────────────
// SEARCH SCREEN
// ──────────────────────────────────────────────
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _query = '';
  final List<String> _recents = [
    'India AI Summit',
    'RBI interest rates',
    'Digital Privacy',
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _query = _controller.text.trim());
    });
    // Auto-focus when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<({int index, ApiArticle article})> get _results {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return allArticles
        .asMap()
        .entries
        .where(
          (e) =>
              e.value.headline.toLowerCase().contains(q) ||
              e.value.source.toLowerCase().contains(q),
        )
        .map(
          (e) => (
            index: e.key,
            article: ApiArticle.fromArticle(e.value, id: e.key),
          ),
        )
        .toList();
  }

  void _applyQuery(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    setState(() => _query = text);
    _focusNode.unfocus();
    // Add to recents
    if (!_recents.contains(text)) {
      setState(() {
        _recents.insert(0, text);
        if (_recents.length > 6) _recents.removeLast();
      });
    }
  }

  void _clearRecent(String item) => setState(() => _recents.remove(item));

  void _clearAll() => setState(() => _recents.clear());

  @override
  Widget build(BuildContext context) {
    final bookmarked = ref.watch(bookmarksProvider);
    final showResults = _query.isNotEmpty;
    final results = _results;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Search bar row ──
            _SearchBar(
              controller: _controller,
              focusNode: _focusNode,
              onClear: () {
                _controller.clear();
                _focusNode.requestFocus();
              },
              onBack: () => Navigator.of(context).pop(),
            ),

            // ── Body ──
            Expanded(
              child: showResults
                  ? _ResultsBody(
                      query: _query,
                      results: results,
                      bookmarked: bookmarked,
                      ref: ref,
                      onSaveSearch: _applyQuery,
                    )
                  : _IdleBody(
                      recents: _recents,
                      onRecentTap: _applyQuery,
                      onClearRecent: _clearRecent,
                      onClearAll: _clearAll,
                      onTopicTap: _applyQuery,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// SEARCH BAR
// ──────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onClear,
    required this.onBack,
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
          // Back button
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

          // Input field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
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
                        hintText: 'Search news, topics, sources…',
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
                  // Clear ×
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, child) {
                      if (value.text.isEmpty) return const SizedBox(width: 12);
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

// ──────────────────────────────────────────────
// IDLE BODY — recents + trending
// ──────────────────────────────────────────────
class _IdleBody extends StatelessWidget {
  const _IdleBody({
    required this.recents,
    required this.onRecentTap,
    required this.onClearRecent,
    required this.onClearAll,
    required this.onTopicTap,
  });

  final List<String> recents;
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
          // ── Recent Searches ──
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
              (r) => _RecentTile(
                text: r,
                onTap: () => onRecentTap(r),
                onDismiss: () => onClearRecent(r),
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ── Trending Topics ──
          Text(
            'Trending Topics',
            style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _trendingTopics.map((topic) {
              return _TopicChip(label: topic, onTap: () => onTopicTap(topic));
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// RESULTS BODY
// ──────────────────────────────────────────────
class _ResultsBody extends StatelessWidget {
  const _ResultsBody({
    required this.query,
    required this.results,
    required this.bookmarked,
    required this.ref,
    required this.onSaveSearch,
  });

  final String query;
  final List<({int index, ApiArticle article})> results;
  final Set<int> bookmarked;
  final WidgetRef ref;
  final ValueChanged<String> onSaveSearch;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return _EmptyResults(query: query);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = results[i];
        return _SearchResultCard(
          article: item.article,
          articleIndex: item.index,
          isBookmarked: bookmarked.contains(item.index),
          onBookmarkTap: () =>
              ref.read(bookmarksProvider.notifier).toggle(item.index),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ImpactScreen(
                  article: item.article,
                  articleIndex: item.index,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
// SEARCH RESULT CARD
// ──────────────────────────────────────────────
class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.article,
    required this.articleIndex,
    required this.isBookmarked,
    required this.onBookmarkTap,
    required this.onTap,
  });

  final ApiArticle article;
  final int articleIndex;
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
          boxShadow: [
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
            // Left accent bar
            Container(width: 3.5, height: 56, color: AppColors.textPrimary),
            const SizedBox(width: 14),

            // Headline + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

            // Bookmark toggle
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

// ──────────────────────────────────────────────
// RECENT SEARCH TILE
// ──────────────────────────────────────────────
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
            // Clock icon
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

// ──────────────────────────────────────────────
// TRENDING TOPIC CHIP
// ──────────────────────────────────────────────
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
          boxShadow: [
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

// ──────────────────────────────────────────────
// EMPTY RESULTS
// ──────────────────────────────────────────────
class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.query});

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

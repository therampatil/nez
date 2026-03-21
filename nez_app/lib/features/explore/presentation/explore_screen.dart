import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/bookmarks_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/nez_top_bar.dart';
import '../../feed/data/feed_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../onboarding/data/preferences_provider.dart';
import 'widgets/explore_article_page.dart';
import 'widgets/explore_feed_states.dart';

const _feedCategories = [
  'Followed News',
  'News Feed',
  'The Daily 12',
  'Laws',
  'Business',
  'Technology',
  'Money',
  'Society',
  'Global',
  'Environment',
  'Career',
  'Social',
  'Education',
];

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  int _selectedCategory = 0;
  int _currentArticleIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCategoryTap(int index) {
    setState(() {
      _selectedCategory = index;
      _currentArticleIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _onHorizontalSwipe(DragEndDetails details) {
    const threshold = 80.0;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > threshold && _selectedCategory > 0) {
      _onCategoryTap(_selectedCategory - 1);
    } else if (velocity < -threshold &&
        _selectedCategory < _feedCategories.length - 1) {
      _onCategoryTap(_selectedCategory + 1);
    }
  }

  List<ApiArticle> _filteredArticles(
    List<ApiArticle> all,
    List<String> userPrefs,
  ) {
    if (all.isEmpty) {
      return [];
    }
    final category = _feedCategories[_selectedCategory];

    if (category == 'Followed News') {
      if (userPrefs.isEmpty) {
        return all;
      }
      final matched = all.where((article) {
        return userPrefs.any(
          (pref) =>
              (article.category ?? '').trim().toLowerCase() ==
              pref.trim().toLowerCase(),
        );
      }).toList();
      return matched.isEmpty ? all : matched;
    }

    if (category == 'News Feed') {
      return all;
    }

    if (category == 'The Daily 12') {
      return all.take(12).toList();
    }

    return all.where((article) {
      return (article.category ?? '').trim().toLowerCase() ==
          category.trim().toLowerCase();
    }).toList();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(feedProvider);
    if (_feedCategories[_selectedCategory] == 'The Daily 12') {
      ref.invalidate(headlinesProvider);
    }
    await ref.read(feedProvider.future);
    if (_feedCategories[_selectedCategory] == 'The Daily 12') {
      await ref.read(headlinesProvider.future);
    }
  }

  IconData _getCategoryIconForTab(String category) {
    switch (category.trim().toLowerCase()) {
      case 'followed news':
        return Icons.star_rounded;
      case 'news feed':
        return Icons.feed_rounded;
      case 'the daily 12':
        return Icons.today_rounded;
      case 'laws':
        return Icons.gavel_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'technology':
        return Icons.computer_rounded;
      case 'money':
        return Icons.currency_rupee_rounded;
      case 'society':
        return Icons.groups_rounded;
      case 'global':
        return Icons.public_rounded;
      case 'environment':
        return Icons.eco_rounded;
      case 'career':
        return Icons.work_rounded;
      case 'social':
        return Icons.people_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _feedCategories[_selectedCategory];
    final isDailyTwelve = selectedCategory == 'The Daily 12';
    final bookmarked = ref.watch(bookmarksProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final feedAsync = ref.watch(feedProvider);
    final headlinesAsync = isDailyTwelve
        ? ref.watch(headlinesProvider)
        : const AsyncValue.data(<ApiArticle>[]);
    ref.watch(bookmarkedArticlesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NezTopBar(showNotificationBadge: unreadCount > 0),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                itemCount: _feedCategories.length,
                separatorBuilder: (_, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategory == index;
                  return GestureDetector(
                    onTap: () => _onCategoryTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.card,
                        border: Border.all(color: AppColors.border, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIconForTab(_feedCategories[index]),
                            size: 16,
                            color: isSelected
                                ? AppColors.background
                                : AppColors.textPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _feedCategories[index],
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isSelected
                                  ? AppColors.background
                                  : AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: feedAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.textPrimary,
                    strokeWidth: 2,
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Failed to load feed',
                          style: AppTextStyles.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => ref.invalidate(feedProvider),
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
                ),
                data: (allArticles) {
                  if (isDailyTwelve) {
                    return headlinesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.textPrimary,
                          strokeWidth: 2,
                        ),
                      ),
                      error: (_, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Failed to load headlines',
                                style: AppTextStyles.headlineMedium,
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => ref.invalidate(headlinesProvider),
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
                      ),
                      data: (headlineArticles) {
                        final userPrefs =
                            ref.watch(preferencesProvider).valueOrNull ?? [];
                        final filtered =
                            _filteredArticles(headlineArticles, userPrefs);
                        final atEnd = filtered.isNotEmpty &&
                            _currentArticleIndex == filtered.length - 1;

                        return _ExploreBody(
                          filtered: filtered,
                          currentCategory: selectedCategory,
                          currentArticleIndex: _currentArticleIndex,
                          onSwipeCategory: _onHorizontalSwipe,
                          onRefresh: _onRefresh,
                          onBrowseAll: () => _onCategoryTap(1),
                          onPageChanged: (index) =>
                              setState(() => _currentArticleIndex = index),
                          pageController: _pageController,
                          bookmarked: bookmarked,
                          ref: ref,
                          atEnd: atEnd,
                        );
                      },
                    );
                  }

                  final userPrefs =
                      ref.watch(preferencesProvider).valueOrNull ?? [];
                  final filtered = _filteredArticles(allArticles, userPrefs);
                  final atEnd = filtered.isNotEmpty &&
                      _currentArticleIndex == filtered.length - 1;

                  return _ExploreBody(
                    filtered: filtered,
                    currentCategory: selectedCategory,
                    currentArticleIndex: _currentArticleIndex,
                    onSwipeCategory: _onHorizontalSwipe,
                    onRefresh: _onRefresh,
                    onBrowseAll: () => _onCategoryTap(1),
                    onPageChanged: (index) =>
                        setState(() => _currentArticleIndex = index),
                    pageController: _pageController,
                    bookmarked: bookmarked,
                    ref: ref,
                    atEnd: atEnd,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreBody extends StatelessWidget {
  const _ExploreBody({
    required this.filtered,
    required this.currentCategory,
    required this.currentArticleIndex,
    required this.onSwipeCategory,
    required this.onRefresh,
    required this.onBrowseAll,
    required this.onPageChanged,
    required this.pageController,
    required this.bookmarked,
    required this.ref,
    required this.atEnd,
  });

  final List<ApiArticle> filtered;
  final String currentCategory;
  final int currentArticleIndex;
  final GestureDragEndCallback onSwipeCategory;
  final Future<void> Function() onRefresh;
  final VoidCallback onBrowseAll;
  final ValueChanged<int> onPageChanged;
  final PageController pageController;
  final Set<int> bookmarked;
  final WidgetRef ref;
  final bool atEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: onSwipeCategory,
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          ExploreCaughtUpBanner(visible: atEnd),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.textPrimary,
              backgroundColor: AppColors.card,
              strokeWidth: 2,
              onRefresh: onRefresh,
              child: filtered.isEmpty
                  ? ExploreEmptyFeedState(
                      category: currentCategory,
                      onBrowseAll: onBrowseAll,
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ExploreProgressRail(
                          itemCount: filtered.length,
                          currentIndex: currentArticleIndex,
                        ),
                        Expanded(
                          child: PageView.builder(
                            controller: pageController,
                            scrollDirection: Axis.vertical,
                            physics: const PageScrollPhysics(),
                            onPageChanged: onPageChanged,
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              return ExploreArticlePage(
                                article: filtered[index],
                                articleIndex: index,
                                total: filtered.length,
                                isBookmarked: bookmarked.contains(
                                  filtered[index].id,
                                ),
                                onBookmarkTap: () => ref
                                    .read(
                                      bookmarkedArticlesProvider.notifier,
                                    )
                                    .toggle(filtered[index]),
                                onSwipeUp: () {
                                  if (pageController.hasClients &&
                                      index < filtered.length - 1) {
                                    pageController.animateToPage(
                                      index + 1,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                              );
                            },
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

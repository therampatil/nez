import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/bookmarks_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/nez_top_bar.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../onboarding/data/preferences_provider.dart';
import '../data/feed_provider.dart';
import 'widgets/legacy_home_article_page.dart';
import 'widgets/legacy_home_states.dart';

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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    await ref.read(feedProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final bookmarked = ref.watch(bookmarksProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final feedAsync = ref.watch(feedProvider);
    ref.watch(bookmarkedArticlesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NezTopBar(showNotificationBadge: unreadCount > 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Explore Categories',
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
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
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.card,
                        border: Border.all(color: AppColors.border, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _feedCategories[index],
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.background
                              : AppColors.textPrimary,
                          fontSize: 14,
                        ),
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
                  final userPrefs =
                      ref.watch(preferencesProvider).valueOrNull ?? [];
                  final filtered = _filteredArticles(allArticles, userPrefs);
                  final atEnd = filtered.isNotEmpty &&
                      _currentArticleIndex == filtered.length - 1;

                  return GestureDetector(
                    onHorizontalDragEnd: _onHorizontalSwipe,
                    behavior: HitTestBehavior.translucent,
                    child: Column(
                      children: [
                        LegacyHomeCaughtUpBanner(visible: atEnd),
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColors.textPrimary,
                            backgroundColor: AppColors.card,
                            strokeWidth: 2,
                            onRefresh: _onRefresh,
                            child: filtered.isEmpty
                                ? LegacyHomeEmptyFeedState(
                                    category:
                                        _feedCategories[_selectedCategory],
                                    onBrowseAll: () => _onCategoryTap(1),
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      LegacyHomeProgressRail(
                                        itemCount: filtered.length,
                                        currentIndex: _currentArticleIndex,
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 420,
                                            ),
                                            child: PageView.builder(
                                              controller: _pageController,
                                              scrollDirection: Axis.vertical,
                                              physics:
                                                  const PageScrollPhysics(),
                                              onPageChanged: (index) =>
                                                  setState(
                                                () => _currentArticleIndex =
                                                    index,
                                              ),
                                              itemCount: filtered.length,
                                              itemBuilder: (context, index) {
                                                return LegacyHomeArticlePage(
                                                  article: filtered[index],
                                                  articleIndex: index,
                                                  total: filtered.length,
                                                  isBookmarked:
                                                      bookmarked.contains(
                                                    filtered[index].id,
                                                  ),
                                                  onBookmarkTap: () => ref
                                                      .read(
                                                        bookmarkedArticlesProvider
                                                            .notifier,
                                                      )
                                                      .toggle(filtered[index]),
                                                  onSwipeUp: () {
                                                    if (_pageController
                                                            .hasClients &&
                                                        index <
                                                            filtered.length -
                                                                1) {
                                                      _pageController
                                                          .animateToPage(
                                                        index + 1,
                                                        duration:
                                                            const Duration(
                                                          milliseconds: 300,
                                                        ),
                                                        curve:
                                                            Curves.easeInOut,
                                                      );
                                                    }
                                                  },
                                                );
                                              },
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/bookmarks_provider.dart';
import '../../../core/providers/followed_stories_provider.dart';
import '../../../shared/widgets/nez_top_bar.dart';
import '../../notifications/providers/notifications_provider.dart';
import 'widgets/followed_news_page.dart';
import 'widgets/followed_news_states.dart';

/// Followed News Screen - Shows updates to news stories the user is following
class FollowedNewsScreen extends ConsumerStatefulWidget {
  const FollowedNewsScreen({super.key});

  @override
  ConsumerState<FollowedNewsScreen> createState() => _FollowedNewsScreenState();
}

class _FollowedNewsScreenState extends ConsumerState<FollowedNewsScreen> {
  int _currentArticleIndex = 0;
  late final PageController _pageController;
  final Set<int> _markedReadStoryIds = <int>{};
  int? _lastAutoMarkedArticleId;
  FollowedNewsViewMode _mode = FollowedNewsViewMode.updates;

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

  Future<void> _onRefresh() async {
    _markedReadStoryIds.clear();
    _lastAutoMarkedArticleId = null;
    ref.invalidate(followedNewsFeedProvider);
    ref.invalidate(followedStoriesProvider);
    await ref.read(followedNewsFeedProvider.future);
  }

  Future<void> _onRefreshStories() async {
    _markedReadStoryIds.clear();
    _lastAutoMarkedArticleId = null;
    ref.invalidate(followedStoriesProvider);
    await ref.read(followedStoriesProvider.future);
  }

  List<int> _storyIdsForArticle({
    required int articleId,
    required List<FollowedStory> stories,
  }) {
    return stories
        .where((story) => story.updates.contains(articleId))
        .map((story) => story.id)
        .toList();
  }

  Future<void> _markStoriesReadForArticle({
    required int articleId,
    required List<FollowedStory> stories,
  }) async {
    final storyIds = _storyIdsForArticle(articleId: articleId, stories: stories)
        .where((id) => !_markedReadStoryIds.contains(id))
        .toList();

    if (storyIds.isEmpty) return;

    final service = ref.read(followStoryProvider);
    var changed = false;

    for (final storyId in storyIds) {
      try {
        await service.markStoryRead(storyId);
        _markedReadStoryIds.add(storyId);
        changed = true;
      } catch (_) {
        // Non-blocking: if mark-read fails, keep the feed usable.
      }
    }

    if (changed) {
      ref.invalidate(followedStoriesProvider);
    }
  }

  String _updateProgressLabel({
    required int articleId,
    required int articleIndex,
    required int feedTotal,
    required List<FollowedStory> stories,
    required Map<int, DateTime?> articleTimeById,
  }) {
    FollowedStory? matchedStory;
    for (final story in stories) {
      if (story.updates.contains(articleId)) {
        matchedStory = story;
        break;
      }
    }

    if (matchedStory == null) {
      return 'update ${articleIndex + 1} of $feedTotal';
    }

    final originalOrder = matchedStory.updates;
    final originalIndexById = <int, int>{};
    for (var i = 0; i < originalOrder.length; i++) {
      originalIndexById[originalOrder[i]] = i;
    }

    final orderedUpdates = List<int>.from(originalOrder);
    orderedUpdates.sort((a, b) {
      final aTime = articleTimeById[a];
      final bTime = articleTimeById[b];

      if (aTime != null && bTime != null) {
        return aTime.compareTo(bTime);
      }
      if (aTime != null) return -1;
      if (bTime != null) return 1;
      return (originalIndexById[a] ?? 0).compareTo(originalIndexById[b] ?? 0);
    });

    final current = orderedUpdates.indexOf(articleId);
    if (current == -1) {
      return 'update ${articleIndex + 1} of $feedTotal';
    }
    return 'update ${current + 1} of ${orderedUpdates.length}';
  }

  @override
  Widget build(BuildContext context) {
    final bookmarked = ref.watch(bookmarksProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final followedFeedAsync = ref.watch(followedNewsFeedProvider);
    final followedStoriesAsync = ref.watch(followedStoriesProvider);
    final totalUnread = ref.watch(followedNewsUnreadCountProvider);
    // Ensure bookmarks are loaded from backend
    ref.watch(bookmarkedArticlesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NezTopBar(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              showNotificationBadge: unreadCount > 0,
            ),
            const SizedBox(height: 20),
            FollowedNewsHeader(
              totalUnread: totalUnread,
              followedStoriesAsync: followedStoriesAsync,
            ),
            const SizedBox(height: 12),
            FollowedNewsViewSwitcher(
              mode: _mode,
              onModeChanged: (mode) => setState(() => _mode = mode),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _mode == FollowedNewsViewMode.following
                  ? followedStoriesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.textPrimary,
                          strokeWidth: 2,
                        ),
                      ),
                      error: (_, _) => FollowedNewsErrorState(
                        onRetry: () => ref.invalidate(followedStoriesProvider),
                      ),
                      data: (stories) => FollowedStoriesListState(
                        stories: stories,
                        onRefresh: _onRefreshStories,
                      ),
                    )
                  : followedFeedAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.textPrimary,
                          strokeWidth: 2,
                        ),
                      ),
                      error: (_, _) => FollowedNewsErrorState(
                        onRetry: () => ref.invalidate(followedNewsFeedProvider),
                      ),
                      data: (articles) {
                        final stories =
                            followedStoriesAsync.valueOrNull ?? const [];
                        final trackedStoriesCount = stories.length;
                        final articleTimeById = <int, DateTime?>{
                          for (final article in articles)
                            article.id: article.publishedAt,
                        };

                        if (articles.isNotEmpty &&
                            _currentArticleIndex < articles.length) {
                          final articleId = articles[_currentArticleIndex].id;
                          if (_lastAutoMarkedArticleId != articleId) {
                            _lastAutoMarkedArticleId = articleId;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _markStoriesReadForArticle(
                                articleId: articleId,
                                stories: stories,
                              );
                            });
                          }
                        }

                        final atEnd =
                            articles.isNotEmpty &&
                            _currentArticleIndex == articles.length - 1;

                        return Column(
                          children: [
                            FollowedNewsCaughtUpBanner(visible: atEnd),
                            Expanded(
                              child: RefreshIndicator(
                                color: AppColors.textPrimary,
                                backgroundColor: AppColors.card,
                                strokeWidth: 2,
                                onRefresh: _onRefresh,
                                child: articles.isEmpty
                                    ? (trackedStoriesCount == 0
                                          ? const FollowedNewsEmptyState()
                                          : FollowedNewsNoUpdatesState(
                                              trackedStories:
                                                  trackedStoriesCount,
                                            ))
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          FollowedNewsProgressRail(
                                            articlesLength: articles.length,
                                            currentArticleIndex:
                                                _currentArticleIndex,
                                          ),
                                          Expanded(
                                            child: PageView.builder(
                                              controller: _pageController,
                                              scrollDirection: Axis.vertical,
                                              physics:
                                                  const PageScrollPhysics(),
                                              onPageChanged: (i) {
                                                setState(
                                                  () => _currentArticleIndex = i,
                                                );
                                                if (i < articles.length) {
                                                  _markStoriesReadForArticle(
                                                    articleId: articles[i].id,
                                                    stories: stories,
                                                  );
                                                }
                                              },
                                              itemCount: articles.length,
                                              itemBuilder: (context, index) {
                                                return FollowedNewsPage(
                                                  article: articles[index],
                                                  isBookmarked: bookmarked
                                                      .contains(
                                                    articles[index].id,
                                                  ),
                                                  onBookmarkTap: () => ref
                                                      .read(
                                                        bookmarkedArticlesProvider
                                                            .notifier,
                                                      )
                                                      .toggle(articles[index]),
                                                  articleIndex: index,
                                                  total: articles.length,
                                                  updateProgressLabel:
                                                      _updateProgressLabel(
                                                    articleId:
                                                        articles[index].id,
                                                    articleIndex: index,
                                                    feedTotal: articles.length,
                                                    stories: stories,
                                                    articleTimeById:
                                                        articleTimeById,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
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

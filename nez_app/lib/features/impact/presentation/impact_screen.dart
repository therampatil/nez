import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/bookmarks_provider.dart';
import '../../../core/providers/shell_tab_provider.dart';
import '../../../core/providers/followed_stories_provider.dart';
import '../../../shared/widgets/nez_bottom_nav.dart';
import '../../../shared/services/interaction_service.dart';
import '../../feed/data/article_model.dart';
import '../../feed/data/feed_provider.dart';
import 'widgets/impact_actions.dart';
import 'widgets/impact_header.dart';
import 'widgets/impact_pager.dart';

// ──────────────────────────────────────────────
// IMPACT SCREEN
// Horizontally swipeable three-panel deep-dive.
// ──────────────────────────────────────────────
class ImpactScreen extends ConsumerStatefulWidget {
  const ImpactScreen({
    super.key,
    required this.article,
    required this.articleIndex,
  });

  /// Accepts the live API article (from the feed).
  final ApiArticle article;
  final int articleIndex;

  @override
  ConsumerState<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends ConsumerState<ImpactScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  final _openedAt = DateTime.now();
  bool _isFollowing = false;

  static const _panelCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    // Record "view" when the article detail screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(interactionServiceProvider).recordView(widget.article.id);
      _checkIfFollowing();
    });
  }

  Future<void> _checkIfFollowing() async {
    if (widget.article.category == null) return;
    try {
      final following = await ref
          .read(followStoryProvider)
          .isFollowing(_generateStoryKey());
      if (mounted) {
        setState(() => _isFollowing = following);
      }
    } catch (e) {
      // Silently fail - not critical
    }
  }

  String _generateStoryKey() {
    // Generate a story key based on article category and title keywords
    // For example: "law-66-ai" from "Law 66 for AI"
    final category = widget.article.category ?? 'general';
    final titleWords = widget.article.title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((w) => w.length > 3)
        .take(3)
        .join('-');
    return '$category-$titleWords';
  }

  Future<void> _toggleFollow() async {
    try {
      final service = ref.read(followStoryProvider);
      final storyKey = _generateStoryKey();

      if (_isFollowing) {
        final stories = await ref.read(followedStoriesProvider.future);
        FollowedStory? story;
        for (final s in stories) {
          if (s.storyKey == storyKey) {
            story = s;
            break;
          }
        }

        if (story == null) {
          setState(() => _isFollowing = false);
          ref.invalidate(followedStoriesProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Follow state refreshed.',
                  style: AppTextStyles.bodySmall,
                ),
                backgroundColor: AppColors.textPrimary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          return;
        }

        await service.unfollowStory(story.id);
        setState(() => _isFollowing = false);
        ref.invalidate(followedStoriesProvider);
        ref.invalidate(followedNewsFeedProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Unfollowed this story.',
                style: AppTextStyles.bodySmall,
              ),
              backgroundColor: AppColors.textPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        await service.followStory(
          articleId: widget.article.id,
          storyKey: storyKey,
          storyTitle: widget.article.title,
        );

        setState(() => _isFollowing = true);

        // Invalidate the followed stories list
        ref.invalidate(followedStoriesProvider);
        ref.invalidate(followedNewsFeedProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Following this story - you\'ll see updates in Following tab',
                style: AppTextStyles.bodySmall,
              ),
              backgroundColor: AppColors.textPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to follow story. Please try again.',
              style: AppTextStyles.bodySmall,
            ),
            backgroundColor: AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Record "read" with actual time spent when the user leaves
    final seconds = DateTime.now().difference(_openedAt).inSeconds.toDouble();
    ref
        .read(interactionServiceProvider)
        .recordRead(widget.article.id, readTimeSeconds: seconds);
    super.dispose();
  }

  /// Build an [ArticleImpact] from an [ApiArticle].
  ///
  /// Maps the news-DB fields:
  ///   overview         → What Happened
  ///   impact           → What You Should Know
  ///   whyThisMatters   → Why It Matters (bullet list)
  ArticleImpact _buildImpact(ApiArticle a) {
    final hasRealData =
        (a.overview?.isNotEmpty == true) ||
        (a.impact?.isNotEmpty == true) ||
        (a.whyThisMatters?.isNotEmpty == true);

    if (hasRealData) {
      return ArticleImpact(
        whatHappened: a.overview?.isNotEmpty == true ? a.overview! : a.title,
        whatYouShouldKnow: a.impact?.isNotEmpty == true
            ? a.impact!
            : 'Stay informed and follow this story for further updates.',
        whyItMatters: a.whyItMattersBullets.isNotEmpty
            ? a.whyItMattersBullets
            : ['Follow credible sources for updates'],
      );
    }

    // Fallback when no backend content is available yet.
    return ArticleImpact(
      whatHappened: a.title,
      whatYouShouldKnow:
          'Stay informed and follow this story for further updates. '
          'More in-depth analysis will be available soon.',
      whyItMatters: [
        'Understand how this affects you',
        'Follow credible sources for updates',
        'Share with others who should know',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final impact = _buildImpact(widget.article);
    final isBookmarked = ref
        .watch(bookmarksProvider)
        .contains(widget.article.id);
    final currentTab = ref.watch(shellTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: NezBottomNav(
        currentIndex: currentTab,
        onTap: (i) {
          ref.read(shellTabProvider.notifier).state = i;
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ImpactHeader(article: widget.article),
            const SizedBox(height: 20),
            SizedBox(
              height: 340,
              child: ImpactCardPager(
                impact: impact,
                pageController: _pageController,
                currentPage: _currentPage,
                onPageChanged: (p) => setState(() => _currentPage = p),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 20),
              child: ImpactPageIndicator(
                count: _panelCount,
                current: _currentPage,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  ImpactIconButton(
                    assetPath: 'assets/images/share.png',
                    onTap: () {
                      final deepLink = 'nez://article/${widget.article.id}';
                      final shareText =
                          '${widget.article.title}\n\nRead this on Nez 👇\n$deepLink';
                      Share.share(shareText, subject: widget.article.title);
                      ref
                          .read(interactionServiceProvider)
                          .recordShare(widget.article.id);
                    },
                  ),
                  const SizedBox(width: 10),
                  ImpactBookmarkButton(
                    isBookmarked: isBookmarked,
                    onTap: () => ref
                        .read(bookmarkedArticlesProvider.notifier)
                        .toggle(widget.article),
                  ),
                  const Spacer(),
                  FollowNewsButton(
                    isFollowing: _isFollowing,
                    onTap: _toggleFollow,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

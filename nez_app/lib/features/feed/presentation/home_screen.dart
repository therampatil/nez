import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/bookmarks_provider.dart';
import '../../../shared/widgets/nez_card.dart';
import '../data/feed_provider.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../search/presentation/search_screen.dart';
import '../../onboarding/data/preferences_provider.dart';
import '../../impact/presentation/impact_screen.dart';

// ──────────────────────────────────────────────
// CATEGORIES
// ──────────────────────────────────────────────
const _feedCategories = [
  'Followed News', // articles matching user's saved preferences
  'News Feed', // all articles
  'The Daily 12', // top 12 ranked
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

// ──────────────────────────────────────────────
// HOME SCREEN
// ──────────────────────────────────────────────
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

  /// Swipe right → previous category, swipe left → next category.
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

  /// Returns articles filtered by selected category.
  /// "Followed News" — articles matching the user's saved preferences.
  ///   Falls back to all articles if no prefs are set or none match.
  /// "News Feed"   — all articles, ranked by the backend.
  /// "The Daily 12" — top 12 articles (already ranked by backend).
  /// Any other tab  — filters by that exact category name (case-insensitive).
  List<ApiArticle> _filteredArticles(
    List<ApiArticle> all,
    List<String> userPrefs,
  ) {
    if (all.isEmpty) return [];
    final cat = _feedCategories[_selectedCategory];

    if (cat == 'Followed News') {
      if (userPrefs.isEmpty) return all;
      final matched = all
          .where(
            (a) => userPrefs.any(
              (pref) =>
                  (a.category ?? '').trim().toLowerCase() ==
                  pref.trim().toLowerCase(),
            ),
          )
          .toList();
      return matched.isEmpty ? all : matched;
    }

    if (cat == 'News Feed') return all;

    if (cat == 'The Daily 12') return all.take(12).toList();

    // Specific category tab — case-insensitive match.
    return all
        .where(
          (a) =>
              (a.category ?? '').trim().toLowerCase() ==
              cat.trim().toLowerCase(),
        )
        .toList();
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
    // Ensure bookmarks are loaded from backend
    ref.watch(bookmarkedArticlesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header: logo + search + bell ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/nez_logo.png',
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                    child: Image.asset(
                      'assets/images/search.png',
                      width: 24,
                      height: 24,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: Center(
                              child: Image.asset(
                                'assets/images/notification.png',
                                width: 24,
                                height: 24,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: AppColors.textPrimary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.background,
                                    width: 1.5,
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
            ),

            const SizedBox(height: 16),

            // ── Category bar ──
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                itemCount: _feedCategories.length,
                separatorBuilder: (_, a) => const SizedBox(width: 10),
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

            // ── Feed content ──
            Expanded(
              child: feedAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.textPrimary,
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => Center(
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
                  final atEnd =
                      filtered.isNotEmpty &&
                      _currentArticleIndex == filtered.length - 1;

                  return GestureDetector(
                    onHorizontalDragEnd: _onHorizontalSwipe,
                    behavior: HitTestBehavior.translucent,
                    child: Column(
                      children: [
                        // ── "All caught up" banner ──
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          child: atEnd
                              ? Container(
                                  margin: const EdgeInsets.fromLTRB(
                                    24,
                                    0,
                                    24,
                                    10,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1.5,
                                    ),
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
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        // ── Article reel ──
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColors.textPrimary,
                            backgroundColor: AppColors.card,
                            strokeWidth: 2,
                            onRefresh: _onRefresh,
                            child: filtered.isEmpty
                                ? _EmptyFeedState(
                                    category:
                                        _feedCategories[_selectedCategory],
                                    onBrowseAll: () => _onCategoryTap(1),
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // ── Anchored vertical progress dots ──
                                      SizedBox(
                                        width: 24,
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(
                                              filtered.length > 12
                                                  ? 12
                                                  : filtered.length,
                                              (i) {
                                                // Map visible dot index to actual page index
                                                final isActive =
                                                    i == _currentArticleIndex ||
                                                    (i == 11 &&
                                                        _currentArticleIndex >=
                                                            11);
                                                return AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 3,
                                                      ),
                                                  width: 6,
                                                  height: isActive ? 22 : 6,
                                                  decoration: BoxDecoration(
                                                    color: isActive
                                                        ? AppColors.textPrimary
                                                        : AppColors
                                                              .textSecondary
                                                              .withValues(
                                                                alpha: 0.35,
                                                              ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          3,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      // ── Article PageView ──
                                      Expanded(
                                        child: PageView.builder(
                                          controller: _pageController,
                                          scrollDirection: Axis.vertical,
                                          physics: const PageScrollPhysics(),
                                          onPageChanged: (i) => setState(
                                            () => _currentArticleIndex = i,
                                          ),
                                          itemCount: filtered.length,
                                          itemBuilder: (context, index) {
                                            return _ArticlePage(
                                              article: filtered[index],
                                              isBookmarked: bookmarked.contains(
                                                filtered[index].id,
                                              ),
                                              onBookmarkTap: () => ref
                                                  .read(
                                                    bookmarkedArticlesProvider
                                                        .notifier,
                                                  )
                                                  .toggle(filtered[index]),
                                              articleIndex: index,
                                              total: filtered.length,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// EMPTY FEED STATE
// ──────────────────────────────────────────────
class _EmptyFeedState extends StatelessWidget {
  const _EmptyFeedState({required this.category, required this.onBrowseAll});

  final String category;
  final VoidCallback onBrowseAll;

  @override
  Widget build(BuildContext context) {
    // Must be scrollable so RefreshIndicator works
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
                  Icons.newspaper_rounded,
                  size: 56,
                  color: AppColors.textSecondary.withValues(alpha: 0.35),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nothing in $category yet',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pull down to refresh, or browse all news below.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: onBrowseAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Browse All News',
                      style: AppTextStyles.labelMedium.copyWith(fontSize: 14),
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
// ARTICLE PAGE — one full-height reel item
// Layout: vertical dots | card | (dots handle page)
// ──────────────────────────────────────────────
class _ArticlePage extends StatelessWidget {
  const _ArticlePage({
    required this.article,
    required this.articleIndex,
    required this.total,
    required this.isBookmarked,
    required this.onBookmarkTap,
  });

  final ApiArticle article;
  final int articleIndex;
  final int total;
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;

  void _showCardMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            _MenuOption(
              icon: Icons.flag_outlined,
              label: 'Report this news',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Thanks for your report.',
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
              },
            ),
            _MenuOption(
              icon: Icons.block_outlined,
              label: 'Not interested in this',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'We\'ll show you less of this.',
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
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 24, 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: NezCard(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Top row: 3-dot menu ──
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showCardMenu(context),
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox(
                        width: 38,
                        height: 38,
                        child: Center(
                          child: Icon(
                            Icons.more_vert_rounded,
                            size: 22,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

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
                            fontSize: 30,
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
                    _ActionIconButton(
                      assetPath: 'assets/images/share.png',
                      onTap: () {
                        final deepLink = 'nez://article/${article.id}';
                        final shareText =
                            '${article.title}\n\n'
                            'Read this on Nez 👇\n'
                            '$deepLink';
                        Share.share(shareText, subject: article.title);
                      },
                    ),
                    const SizedBox(width: 8),
                    _BookmarkButton(
                      isBookmarked: isBookmarked,
                      onTap: onBookmarkTap,
                    ),
                    const Spacer(),
                    // ── See the Impact button ──
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ImpactScreen(
                              article: article,
                              articleIndex: articleIndex,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          border: Border.all(
                            color: AppColors.accent,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'See the Impact',
                              style: AppTextStyles.labelMedium.copyWith(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward,
                              size: 15,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Swipe hint
                if (articleIndex < total - 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'swipe up',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
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
// CARD MENU OPTION
// ──────────────────────────────────────────────
class _MenuOption extends StatelessWidget {
  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.textPrimary),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// BOOKMARK BUTTON — toggles filled / outline
// ──────────────────────────────────────────────
class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.isBookmarked, required this.onTap});

  final bool isBookmarked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isBookmarked ? AppColors.accent : Colors.transparent,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/bookmark.png',
            width: 18,
            height: 18,
            color: isBookmarked ? Colors.white : AppColors.textPrimary,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// ACTION ICON BUTTON (share)
// ──────────────────────────────────────────────
class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({required this.assetPath, required this.onTap});

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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 18,
            height: 18,
            color: AppColors.textPrimary,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/bookmarks_provider.dart';
import '../../../core/providers/shell_tab_provider.dart';
import '../../../shared/widgets/nez_bottom_nav.dart';
import '../../../shared/services/interaction_service.dart';
import '../../feed/data/article_model.dart';
import '../../feed/data/feed_provider.dart';

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

  static const _panelCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    // Record "view" when the article detail screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(interactionServiceProvider).recordView(widget.article.id);
    });
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

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: NezBottomNav(
        currentIndex: 0, // Home is active while viewing an article
        onTap: (i) {
          // Write the desired tab index to the provider, then pop back to shell
          ref.read(shellTabProvider.notifier).state = i;
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            _Header(article: widget.article),

            const SizedBox(height: 20),

            // ── Card PageView — fixed height so buttons sit below ──
            SizedBox(
              height: 340,
              child: _CardPager(
                impact: impact,
                pageController: _pageController,
                currentPage: _currentPage,
                onPageChanged: (p) => setState(() => _currentPage = p),
              ),
            ),

            // ── Page indicator ──
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 20),
              child: _PageIndicator(count: _panelCount, current: _currentPage),
            ),

            // ── Action buttons — send / bookmark / Follow News ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Send / share
                  _ImpactIconButton(
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
                  // Bookmark
                  _ImpactBookmarkButton(
                    isBookmarked: isBookmarked,
                    onTap: () => ref
                        .read(bookmarkedArticlesProvider.notifier)
                        .toggle(widget.article),
                  ),
                  const Spacer(),
                  // Follow News →
                  _FollowNewsButton(onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// HEADER — back + logo + article headline
// ──────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.article});

  final ApiArticle article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + logo row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.arrow_back,
                    size: 22,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/images/nez_logo.png',
                height: 32,
                fit: BoxFit.contain,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Headline with left accent bar
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3.5, color: AppColors.textPrimary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 20,
                          height: 1.3,
                        ),
                        softWrap: true,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            article.timeAgo,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Flexible(
                            child: Text(
                              'Source - ${article.source ?? ''}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// CARD PAGER — horizontally scrollable 3-panel
// ──────────────────────────────────────────────
class _CardPager extends StatelessWidget {
  const _CardPager({
    required this.impact,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
  });

  final ArticleImpact impact;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final panels = [
      _PanelData(
        label: 'OVERVIEW',
        labelIndex: '01',
        content: impact.whatHappened,
        type: _PanelType.paragraph,
      ),
      _PanelData(
        label: 'IN CONTEXT',
        labelIndex: '02',
        content: impact.whatYouShouldKnow,
        type: _PanelType.paragraph,
      ),
      _PanelData(
        label: 'WHY IT MATTERS',
        labelIndex: '03',
        content: '',
        bullets: impact.whyItMatters,
        type: _PanelType.bullets,
      ),
    ];

    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      physics: const BouncingScrollPhysics(),
      itemCount: panels.length,
      itemBuilder: (context, index) {
        final panel = panels[index];
        final isActive = index == currentPage;
        return AnimatedScale(
          scale: isActive ? 1.0 : 0.95,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: _ImpactCard(panel: panel, index: index, total: panels.length),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
// IMPACT CARD
// ──────────────────────────────────────────────
class _ImpactCard extends StatelessWidget {
  const _ImpactCard({
    required this.panel,
    required this.index,
    required this.total,
  });

  final _PanelData panel;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card top bar ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Label
                  Expanded(
                    child: Text(
                      panel.label,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 13,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Counter e.g. 01 / 03
                  Text(
                    '${panel.labelIndex} / 0$total',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // ── Card body ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: panel.type == _PanelType.bullets
                    ? _BulletsBody(bullets: panel.bullets ?? [])
                    : _ParagraphBody(text: panel.content),
              ),
            ),

            // ── Swipe nudge ──
            if (index < total - 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'swipe',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.textHint,
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

// ──────────────────────────────────────────────
// PARAGRAPH BODY
// ──────────────────────────────────────────────
class _ParagraphBody extends StatelessWidget {
  const _ParagraphBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // Split on \n to render paragraphs with spacing
    final paragraphs = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < paragraphs.length; i++) ...[
          if (paragraphs[i].trim().isNotEmpty)
            Text(
              paragraphs[i].trim(),
              style: AppTextStyles.bodyLarge.copyWith(
                height: 1.6,
                color: AppColors.textPrimary,
              ),
              softWrap: true,
            ),
          if (i < paragraphs.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────
// BULLETS BODY
// ──────────────────────────────────────────────
class _BulletsBody extends StatelessWidget {
  const _BulletsBody({required this.bullets});

  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bullets.map((b) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom bullet square
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 12),
                child: Container(
                  width: 6,
                  height: 6,
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: Text(
                  b,
                  style: AppTextStyles.bodyLarge.copyWith(
                    height: 1.55,
                    color: AppColors.textPrimary,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────────
// PAGE INDICATOR — horizontal dots
// ──────────────────────────────────────────────
class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.textPrimary
                : AppColors.textSecondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ──────────────────────────────────────────────
// ICON BUTTON (send / share) — matches home card
// ──────────────────────────────────────────────
class _ImpactIconButton extends StatelessWidget {
  const _ImpactIconButton({required this.assetPath, required this.onTap});

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
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// BOOKMARK BUTTON — filled when saved
// ──────────────────────────────────────────────
class _ImpactBookmarkButton extends StatelessWidget {
  const _ImpactBookmarkButton({
    required this.isBookmarked,
    required this.onTap,
  });

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
          color: isBookmarked ? AppColors.textPrimary : Colors.transparent,
          border: Border.all(color: AppColors.border, width: 1.5),
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
// FOLLOW NEWS BUTTON — matches "See the impact"
// ──────────────────────────────────────────────
class _FollowNewsButton extends StatelessWidget {
  const _FollowNewsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Follow News',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// DATA MODELS — internal to this screen
// ──────────────────────────────────────────────
enum _PanelType { paragraph, bullets }

class _PanelData {
  const _PanelData({
    required this.label,
    required this.labelIndex,
    required this.content,
    required this.type,
    this.bullets,
  });

  final String label;
  final String labelIndex;
  final String content;
  final _PanelType type;
  final List<String>? bullets;
}

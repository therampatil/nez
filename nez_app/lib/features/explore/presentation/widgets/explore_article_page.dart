import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/nez_card.dart';
import '../../../feed/data/feed_provider.dart';
import '../../../impact/presentation/impact_screen.dart';

class ExploreArticlePage extends ConsumerStatefulWidget {
  const ExploreArticlePage({
    required this.article,
    required this.articleIndex,
    required this.total,
    required this.isBookmarked,
    required this.onBookmarkTap,
    required this.onSwipeUp,
    super.key,
  });

  final ApiArticle article;
  final int articleIndex;
  final int total;
  final bool isBookmarked;
  final VoidCallback onBookmarkTap;
  final VoidCallback onSwipeUp;

  @override
  ConsumerState<ExploreArticlePage> createState() => _ExploreArticlePageState();
}

class _ExploreArticlePageState extends ConsumerState<ExploreArticlePage> {
  void _showCardMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
    final imageUrl = (widget.article.imageUrl?.trim().isNotEmpty ?? false)
        ? widget.article.imageUrl!.trim()
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImpactScreen(
              article: widget.article,
              articleIndex: widget.articleIndex,
            ),
          ),
        );
      },
      child: Padding(
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
                  if (widget.article.category != null &&
                      widget.article.category!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(widget.article.category!),
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${widget.article.category}',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(width: 3.5, color: AppColors.textPrimary),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            widget.article.title,
                            style: AppTextStyles.displayMedium.copyWith(
                              fontSize: 24,
                              height: 1.18,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (imageUrl != null) ...[
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 168,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.backgroundElevated,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              size: 24,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        widget.article.timeAgo,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Text(
                          'Source - ${widget.article.source ?? ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _ActionIconButton(
                        assetPath: 'assets/images/share.png',
                        onTap: () {
                          final deepLink = 'nez://article/${widget.article.id}';
                          final shareText =
                              '${widget.article.title}\n\nRead this on Nez 👇\n$deepLink';
                          Share.share(shareText, subject: widget.article.title);
                        },
                      ),
                      const SizedBox(width: 8),
                      _BookmarkButton(
                        isBookmarked: widget.isBookmarked,
                        onTap: widget.onBookmarkTap,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ImpactScreen(
                                article: widget.article,
                                articleIndex: widget.articleIndex,
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
                  if (widget.articleIndex < widget.total - 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: widget.onSwipeUp,
                            behavior: HitTestBehavior.opaque,
                            child: Row(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.trim().toLowerCase();
    switch (cat) {
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
}

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

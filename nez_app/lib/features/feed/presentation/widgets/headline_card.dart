import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/providers/bookmarks_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/feed_provider.dart';
import '../../../impact/presentation/impact_screen.dart';

class HeadlineCard extends ConsumerWidget {
  const HeadlineCard({required this.article, required this.index, super.key});

  final ApiArticle article;
  final int index;

  String _getTimeAgo(DateTime? date) {
    if (date == null) return '';
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.newspaper_rounded;
    final cat = category.toLowerCase();
    if (cat.contains('tech')) return Icons.code_rounded;
    if (cat.contains('business')) return Icons.business_center_rounded;
    if (cat.contains('finance') || cat.contains('money')) {
      return Icons.account_balance_wallet_rounded;
    }
    if (cat.contains('law') || cat.contains('legal')) {
      return Icons.gavel_rounded;
    }
    if (cat.contains('society') || cat.contains('social')) {
      return Icons.people_rounded;
    }
    if (cat.contains('global') || cat.contains('world')) {
      return Icons.public_rounded;
    }
    if (cat.contains('education')) return Icons.school_rounded;
    if (cat.contains('health')) return Icons.favorite_rounded;
    if (cat.contains('environment') || cat.contains('climate')) {
      return Icons.eco_rounded;
    }
    if (cat.contains('sport')) return Icons.sports_rounded;
    return Icons.newspaper_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);
    final isBookmarked = bookmarks.contains(article.id);
    final timeAgo = _getTimeAgo(article.publishedAt);
    final overview = article.overview?.trim();
    final source = (article.source?.trim().isNotEmpty ?? false)
        ? article.source!.trim()
        : 'Nez Wire';
    final imageUrl = (article.imageUrl?.trim().isNotEmpty ?? false)
        ? article.imageUrl!.trim()
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 18, 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: AppColors.textPrimary,
          border: Border.all(color: AppColors.border, width: 1.6),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowStrong,
              blurRadius: 0,
              offset: const Offset(10, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            color: AppColors.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevated,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.borderLight,
                        width: 1.2,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetaChip(
                        icon: _getCategoryIcon(article.category),
                        label: article.category?.toUpperCase() ?? 'NEWS',
                        filled: true,
                      ),
                      const Spacer(),
                      Text(
                        '#${index + 1}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              constraints: const BoxConstraints(minHeight: 92),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.22,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                article.title,
                                style: AppTextStyles.displayMedium.copyWith(
                                  fontSize: 23,
                                  height: 1.14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (imageUrl != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: double.infinity,
                              height: 140,
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
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 14,
                          runSpacing: 6,
                          children: [
                            if (timeAgo.isNotEmpty)
                              Text(
                                timeAgo,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            Text(
                              'Source - $source',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(height: 1.2, color: AppColors.borderLight),
                        const SizedBox(height: 14),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              overview?.isNotEmpty == true
                                  ? overview!
                                  : 'Open the impact view for the full contextual breakdown and why this story matters.',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontSize: 14,
                                height: 1.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _ActionIconButton(
                              icon: Icons.send_rounded,
                              onTap: () {
                                final deepLink = 'nez://article/${article.id}';
                                final shareText =
                                    '${article.title}\n\nRead this on Nez 👇\n$deepLink';
                                Share.share(shareText, subject: article.title);
                              },
                            ),
                            const SizedBox(width: 12),
                            _ActionIconButton(
                              icon: isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              active: isBookmarked,
                              onTap: () => ref
                                  .read(bookmarkedArticlesProvider.notifier)
                                  .toggle(article),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(4),
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
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundElevated,
                                    border: Border.all(
                                      color: AppColors.textPrimary,
                                      width: 1.4,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.shadowStrong,
                                        blurRadius: 0,
                                        offset: Offset(6, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'See the impact',
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.labelMedium
                                              .copyWith(
                                                color: AppColors.textPrimary,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: AppColors.accent,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: filled ? AppColors.backgroundElevated : AppColors.card,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: filled ? AppColors.textPrimary : AppColors.borderLight,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 0,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: filled ? AppColors.accent : AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: active ? AppColors.textPrimary : AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active ? AppColors.textPrimary : AppColors.borderLight,
            width: 1.3,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowStrong,
              blurRadius: 0,
              offset: Offset(6, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: active ? AppColors.background : AppColors.textPrimary,
          size: 22,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../feed/data/article_model.dart';
import 'impact_models.dart';

class ImpactCardPager extends StatelessWidget {
  const ImpactCardPager({
    required this.impact,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    super.key,
  });

  final ArticleImpact impact;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final panels = buildImpactPanels(impact);

    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      physics: const BouncingScrollPhysics(),
      itemCount: panels.length,
      itemBuilder: (context, index) {
        final panel = panels[index];
        final isActive = index == currentPage;
        return AnimatedScale(
          scale: isActive ? 1 : 0.95,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: ImpactCard(panel: panel, index: index, total: panels.length),
        );
      },
    );
  }
}

class ImpactCard extends StatelessWidget {
  const ImpactCard({
    required this.panel,
    required this.index,
    required this.total,
    super.key,
  });

  final PanelData panel;
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
          boxShadow: const [
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1.5),
                ),
              ),
              child: Row(
                children: [
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
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: panel.type == PanelType.bullets
                    ? BulletsBody(bullets: panel.bullets ?? [])
                    : ParagraphBody(text: panel.content),
              ),
            ),
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

class ParagraphBody extends StatelessWidget {
  const ParagraphBody({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
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

class BulletsBody extends StatelessWidget {
  const BulletsBody({required this.bullets, super.key});

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

class ImpactPageIndicator extends StatelessWidget {
  const ImpactPageIndicator({required this.count, required this.current, super.key});

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

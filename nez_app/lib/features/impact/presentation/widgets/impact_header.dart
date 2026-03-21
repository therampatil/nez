import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../feed/data/feed_provider.dart';

class ImpactHeader extends StatelessWidget {
  const ImpactHeader({required this.article, super.key});

  final ApiArticle article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

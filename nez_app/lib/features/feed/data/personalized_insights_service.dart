import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'personalized_insight.dart';

class PersonalizedInsightsService {
  List<PersonalizedInsight> buildInsights(List<String> preferences) {
    if (preferences.isEmpty) {
      return [
        PersonalizedInsight(
          category: 'Business',
          icon: Icons.business_center_rounded,
          title: 'Indian Startup Ecosystem Growth',
          insight:
              'India added 1,300+ new startups in Q1 2025. Tech, fintech, and edtech sectors are leading. Government\'s Startup India initiative provides tax benefits for first 3 years.',
          actionLabel: 'Explore Opportunities',
          color: AppColors.accent,
        ),
        PersonalizedInsight(
          category: 'Technology',
          icon: Icons.code_rounded,
          title: 'AI & ML Job Market Surge',
          insight:
              'Demand for AI/ML professionals grew 230% in 2024. Average salary: Rs12-25 LPA. Free certifications available from Google, Microsoft, and IBM.',
          actionLabel: 'Learn More',
          color: AppColors.textPrimary,
        ),
      ];
    }

    final insights = <PersonalizedInsight>[];

    for (final preference in preferences.take(3)) {
      final prefLower = preference.toLowerCase();

      if (prefLower.contains('business') || prefLower.contains('startup')) {
        insights.add(
          PersonalizedInsight(
            category: 'Business',
            icon: Icons.business_center_rounded,
            title: 'Startup Funding Trends 2025',
            insight:
                'Seed funding rounds increased 45% this quarter. Focus areas: Climate tech, healthtech, and SaaS. Angel tax benefits extended until 2026.',
            actionLabel: 'View Funding Sources',
            color: AppColors.accent,
          ),
        );
      } else if (prefLower.contains('tech') ||
          prefLower.contains('career')) {
        insights.add(
          PersonalizedInsight(
            category: 'Career',
            icon: Icons.rocket_launch_rounded,
            title: 'Remote Work Opportunities',
            insight:
                '68% of Indian companies now offer hybrid or remote roles. Top skills in demand: Cloud, DevOps, Product Management. Avg salary increase: 15-20%.',
            actionLabel: 'Explore Jobs',
            color: AppColors.textPrimary,
          ),
        );
      } else if (prefLower.contains('money') ||
          prefLower.contains('finance')) {
        insights.add(
          PersonalizedInsight(
            category: 'Finance',
            icon: Icons.account_balance_wallet_rounded,
            title: 'Investment Insights',
            insight:
                'New income tax slabs effective April 2025. SIP investments hit all-time high. Consider diversifying with debt funds for stable returns.',
            actionLabel: 'Learn Investing',
            color: AppColors.accent,
          ),
        );
      } else if (prefLower.contains('education')) {
        insights.add(
          PersonalizedInsight(
            category: 'Education',
            icon: Icons.school_rounded,
            title: 'Upskilling Opportunities',
            insight:
                'Government\'s Skill India program offers free courses in 200+ domains. Micro-credentials gaining value. Focus: Digital marketing, data analytics.',
            actionLabel: 'Discover Courses',
            color: AppColors.textPrimary,
          ),
        );
      }
    }

    if (insights.isEmpty) {
      insights.add(
        PersonalizedInsight(
          category: 'General',
          icon: Icons.lightbulb_outline_rounded,
          title: 'Stay Informed, Stay Ahead',
          insight:
              'Customize your preferences to receive personalized insights on startups, career growth, investments, and opportunities tailored just for you.',
          actionLabel: 'Set Preferences',
          color: AppColors.textSecondary,
        ),
      );
    }

    return insights.take(2).toList();
  }
}

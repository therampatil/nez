/// Mirrors the backend InsightsResponse schema.
class InsightsData {
  const InsightsData({
    required this.totalArticlesRead,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalReadSeconds,
    required this.thisWeekReadSeconds,
    required this.todayReadSeconds,
    required this.weeklyReads,
    required this.streakGrid,
    required this.topCategories,
  });

  final int totalArticlesRead;
  final int currentStreak;
  final int longestStreak;
  final double totalReadSeconds;
  final double thisWeekReadSeconds;
  final double todayReadSeconds;
  final List<int> weeklyReads; // 7 values, Mon–Sun
  final List<bool> streakGrid; // 35 values, oldest→newest
  final List<CategoryStat> topCategories;

  factory InsightsData.fromJson(Map<String, dynamic> json) {
    return InsightsData(
      totalArticlesRead: (json['total_articles_read'] as num).toInt(),
      currentStreak: (json['current_streak'] as num).toInt(),
      longestStreak: (json['longest_streak'] as num).toInt(),
      totalReadSeconds: (json['total_read_seconds'] as num).toDouble(),
      thisWeekReadSeconds: (json['this_week_read_seconds'] as num).toDouble(),
      todayReadSeconds: (json['today_read_seconds'] as num).toDouble(),
      weeklyReads: (json['weekly_reads'] as List)
          .map((e) => (e as num).toInt())
          .toList(),
      streakGrid: (json['streak_grid'] as List).map((e) => e as bool).toList(),
      topCategories: (json['top_categories'] as List)
          .map((e) => CategoryStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Format seconds as "1h 23m", "45m", or "18.4h" depending on magnitude.
  static String formatSeconds(double secs) {
    if (secs <= 0) return '0m';
    final h = (secs / 3600).floor();
    final m = ((secs % 3600) / 60).round();
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

class CategoryStat {
  const CategoryStat({
    required this.label,
    required this.count,
    required this.pct,
  });

  final String label;
  final int count;
  final double pct;

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      label: json['label'] as String,
      count: (json['count'] as num).toInt(),
      pct: (json['pct'] as num).toDouble(),
    );
  }
}

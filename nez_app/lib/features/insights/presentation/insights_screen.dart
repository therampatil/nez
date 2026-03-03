import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../data/insights_provider.dart';
import '../data/insights_model.dart';

// ──────────────────────────────────────────────
// INSIGHTS SCREEN  (live data from /users/me/insights)
// ──────────────────────────────────────────────
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  static const _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              color: AppColors.textPrimary,
              onRefresh: () => ref.refresh(insightsProvider.future),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(bottom: 48),
                child: Padding(
                  padding: const EdgeInsets.only(left: 76, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Insights',
                        style: AppTextStyles.displayMedium,
                        maxLines: 1,
                      ),
                      Text(
                        'Your reading at a glance',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      insightsAsync.when(
                        loading: () => const _LoadingBody(),
                        error: (e, _) => _ErrorBody(
                          message: e.toString(),
                          onRetry: () => ref.refresh(insightsProvider.future),
                        ),
                        data: (data) =>
                            _InsightsBody(data: data, weekDays: _weekDays),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Loading / Error ──────────────────────────────
class _LoadingBody extends StatelessWidget {
  const _LoadingBody();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 300,
    child: Center(child: CircularProgressIndicator()),
  );
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              'Could not load insights',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ── Live data body ───────────────────────────────
class _InsightsBody extends StatelessWidget {
  const _InsightsBody({required this.data, required this.weekDays});
  final InsightsData data;
  final List<String> weekDays;

  @override
  Widget build(BuildContext context) {
    final streakLabel = data.currentStreak > 0
        ? '🔥 ${data.currentStreak}-day streak · Keep it up!'
        : 'No active streak — start reading today!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatsRow(data: data),
        const SizedBox(height: 20),
        _SectionCard(
          title: 'Reading Streak',
          subtitle: streakLabel,
          child: _StreakCalendar(grid: data.streakGrid, weekDays: weekDays),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'This Week',
          subtitle: 'Articles read per day',
          child: _WeeklyBarChart(reads: data.weeklyReads, weekDays: weekDays),
        ),
        const SizedBox(height: 16),
        if (data.topCategories.isNotEmpty) ...[
          _SectionCard(
            title: 'Top Categories',
            subtitle: "Based on articles you've read",
            child: _CategoryBreakdown(categories: data.topCategories),
          ),
          const SizedBox(height: 16),
        ],
        _SectionCard(
          title: 'Time Spent Reading',
          subtitle: 'Total across all articles',
          child: _ReadingTimeRow(data: data),
        ),
      ],
    );
  }
}

// ── Stat Cards ────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});
  final InsightsData data;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _StatCard(
          value: '${data.totalArticlesRead}',
          label: 'Articles\nRead',
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _StatCard(value: '${data.currentStreak}', label: 'Day\nStreak'),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _StatCard(
          value: InsightsData.formatSeconds(data.thisWeekReadSeconds),
          label: 'Time\nThis Week',
        ),
      ),
    ],
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF000000),
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.headlineLarge.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF000000),
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(18), child: child),
        ],
      ),
    );
  }
}

// ── Streak Calendar ───────────────────────────────
class _StreakCalendar extends StatelessWidget {
  const _StreakCalendar({required this.grid, required this.weekDays});
  final List<bool> grid;
  final List<String> weekDays;

  @override
  Widget build(BuildContext context) {
    final cells = List<bool>.from(grid);
    while (cells.length < 35) {
      cells.insert(0, false);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays
              .map(
                (d) => SizedBox(
                  width: 28,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        ...List.generate(5, (row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (col) {
                final idx = row * 7 + col;
                final active = idx < cells.length && cells[idx];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.textPrimary
                        : AppColors.background,
                    border: Border.all(
                      color: active ? AppColors.border : AppColors.divider,
                      width: 1,
                    ),
                  ),
                );
              }),
            ),
          );
        }),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(width: 12, height: 12, color: AppColors.textPrimary),
            const SizedBox(width: 6),
            Text(
              'Read',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.divider),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Missed',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Weekly Bar Chart ──────────────────────────────
class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.reads, required this.weekDays});
  final List<int> reads;
  final List<String> weekDays;

  @override
  Widget build(BuildContext context) {
    final maxVal = reads.fold<int>(1, (p, e) => e > p ? e : p).toDouble();
    final today = DateTime.now().weekday - 1;

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final val = i < reads.length ? reads[i] : 0;
          final pct = val / maxVal;
          final isToday = i == today;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$val',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  color: isToday
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                width: 28,
                height: 80 * pct,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.textPrimary
                      : AppColors.textSecondary.withValues(alpha: 0.25),
                  border: Border.all(
                    color: isToday ? AppColors.border : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                i < weekDays.length ? weekDays[i] : '',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  color: isToday
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Category Breakdown ────────────────────────────
class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.categories});
  final List<CategoryStat> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: categories.map((cat) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cat.label,
                    style: AppTextStyles.labelMedium.copyWith(fontSize: 13),
                  ),
                  Text(
                    '${cat.count} articles · ${(cat.pct * 100).round()}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LayoutBuilder(
                builder: (_, constraints) => Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      color: AppColors.background,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      height: 8,
                      width: constraints.maxWidth * cat.pct,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Reading Time Row ─────────────────────────────
class _ReadingTimeRow extends StatelessWidget {
  const _ReadingTimeRow({required this.data});
  final InsightsData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TimeStatBlock(
          value: InsightsData.formatSeconds(data.totalReadSeconds),
          label: 'Total\nAll Time',
        ),
        _TimeDivider(),
        _TimeStatBlock(
          value: InsightsData.formatSeconds(data.thisWeekReadSeconds),
          label: 'This\nWeek',
        ),
        _TimeDivider(),
        _TimeStatBlock(
          value: InsightsData.formatSeconds(data.todayReadSeconds),
          label: 'Today',
        ),
      ],
    );
  }
}

class _TimeStatBlock extends StatelessWidget {
  const _TimeStatBlock({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.3,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeDivider extends StatelessWidget {
  const _TimeDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 48, color: AppColors.divider);
}

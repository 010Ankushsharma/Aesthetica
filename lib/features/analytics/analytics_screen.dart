import 'package:aesthetica/core/constants/app_colors.dart';
import 'package:aesthetica/core/constants/app_spacing.dart';
import 'package:aesthetica/core/utils/extensions.dart';
import 'package:aesthetica/core/widgets/glass_card.dart';
import 'package:aesthetica/core/widgets/stat_card.dart';
import 'package:aesthetica/data/repositories/providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ChartPeriod { weekly, monthly, yearly }

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final stats = ref.watch(dailyStatsProvider);
    final weeklyCalories = ref.watch(weeklyCaloriesProvider);
    final monthlyWeight = ref.watch(monthlyWeightProvider);

    return _AnalyticsBody(
      profile: profile,
      stats: stats,
      weeklyCalories: weeklyCalories,
      monthlyWeight: monthlyWeight,
    );
  }
}

class _AnalyticsBody extends StatefulWidget {
  const _AnalyticsBody({
    required this.profile,
    required this.stats,
    required this.weeklyCalories,
    required this.monthlyWeight,
  });

  final dynamic profile;
  final dynamic stats;
  final List<double> weeklyCalories;
  final List<double> monthlyWeight;

  @override
  State<_AnalyticsBody> createState() => _AnalyticsBodyState();
}

class _AnalyticsBodyState extends State<_AnalyticsBody> {
  _ChartPeriod _period = _ChartPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Header(period: _period, onPeriodChanged: (p) => setState(() => _period = p))),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _AnimatedStatsRow(
                  calories: widget.stats.caloriesBurned,
                  workouts: widget.stats.workoutMinutes,
                  streak: widget.profile.streak,
                  recovery: widget.stats.recoveryScore,
                ),
                const SizedBox(height: AppSpacing.lg),
                _MainChart(
                  period: _period,
                  weeklyCalories: widget.weeklyCalories,
                  monthlyWeight: widget.monthlyWeight,
                ),
                const SizedBox(height: AppSpacing.lg),
                _ConsistencyHeatmap(),
                const SizedBox(height: AppSpacing.lg),
                _MuscleBalanceChart(),
                const SizedBox(height: AppSpacing.lg),
                _TransformationGraph(data: widget.monthlyWeight),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.period, required this.onPeriodChanged});

  final _ChartPeriod period;
  final ValueChanged<_ChartPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.paddingOf(context).top + AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: context.textTheme.displaySmall,
          ).animate().fadeIn().slideX(begin: -0.1, end: 0),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Insights & performance trends',
            style: context.textTheme.bodyMedium?.copyWith(color: AppColors.grey),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: _ChartPeriod.values.map((p) {
              final isSelected = p == period;
              final label = switch (p) {
                _ChartPeriod.weekly => 'Weekly',
                _ChartPeriod.monthly => 'Monthly',
                _ChartPeriod.yearly => 'Yearly',
              };
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: p != _ChartPeriod.yearly ? AppSpacing.sm : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      context.hapticSelection();
                      onPeriodChanged(p);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.accentGradient : null,
                        color: isSelected ? null : AppColors.card,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: isSelected ? AppColors.white : AppColors.grey,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

class _AnimatedStatsRow extends StatelessWidget {
  const _AnimatedStatsRow({
    required this.calories,
    required this.workouts,
    required this.streak,
    required this.recovery,
  });

  final int calories;
  final int workouts;
  final int streak;
  final int recovery;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Calories',
            value: calories.formatted,
            unit: 'kcal',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.accent,
          ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9)),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatCard(
            label: 'Workout',
            value: '$workouts',
            unit: 'min',
            icon: Icons.timer_rounded,
            color: AppColors.green,
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatCard(
            label: 'Streak',
            value: '$streak',
            unit: 'days',
            icon: Icons.local_fire_department,
            color: AppColors.red,
          ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatCard(
            label: 'Recovery',
            value: '$recovery',
            unit: '%',
            icon: Icons.self_improvement_rounded,
            color: AppColors.blue,
          ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
        ),
      ],
    );
  }
}

class _MainChart extends StatelessWidget {
  const _MainChart({
    required this.period,
    required this.weeklyCalories,
    required this.monthlyWeight,
  });

  final _ChartPeriod period;
  final List<double> weeklyCalories;
  final List<double> monthlyWeight;

  @override
  Widget build(BuildContext context) {
    final title = switch (period) {
      _ChartPeriod.weekly => 'Weekly Calories',
      _ChartPeriod.monthly => 'Monthly Weight',
      _ChartPeriod.yearly => 'Yearly Overview',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            height: 220,
            child: switch (period) {
              _ChartPeriod.weekly => _WeeklyBarChart(data: weeklyCalories),
              _ChartPeriod.monthly => _MonthlyLineChart(data: monthlyWeight),
              _ChartPeriod.yearly => _YearlyAreaChart(
                  calories: weeklyCalories,
                  weight: monthlyWeight,
                ),
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.data});

  final List<double> data;

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 2500,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.cardElevated,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              '${rod.toY.toInt()} kcal',
              context.textTheme.labelMedium!.copyWith(color: AppColors.white),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                days[value.toInt()],
                style: context.textTheme.labelSmall,
              ),
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 500,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.border.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          data.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                gradient: i == data.length - 1
                    ? AppColors.accentGradient
                    : LinearGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.45),
                          AppColors.accent.withValues(alpha: 0.2),
                        ],
                      ),
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ),
        ),
      ),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );
  }
}

class _MonthlyLineChart extends StatelessWidget {
  const _MonthlyLineChart({required this.data});

  final List<double> data;

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i]),
    );

    return LineChart(
      LineChartData(
        minY: data.reduce((a, b) => a < b ? a : b) - 1,
        maxY: data.reduce((a, b) => a > b ? a : b) + 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.border.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) => Text(
                'W${value.toInt() + 1}',
                style: context.textTheme.labelSmall,
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: context.textTheme.labelSmall,
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.green,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.green,
                strokeWidth: 2,
                strokeColor: AppColors.card,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.green.withValues(alpha: 0.3),
                  AppColors.green.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
    );
  }
}

class _YearlyAreaChart extends StatelessWidget {
  const _YearlyAreaChart({required this.calories, required this.weight});

  final List<double> calories;
  final List<double> weight;

  @override
  Widget build(BuildContext context) {
    final months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    final calorieSpots = List.generate(12, (i) {
      final src = calories[i % calories.length];
      return FlSpot(i.toDouble(), src * (0.9 + (i % 3) * 0.05));
    });
    final weightSpots = List.generate(8, (i) => FlSpot(i.toDouble() * 1.5, weight[i]));

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.border.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (value, meta) => Text(
                months[value.toInt().clamp(0, 11)],
                style: context.textTheme.labelSmall,
              ),
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: calorieSpots,
            isCurved: true,
            color: AppColors.accent,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accent.withValues(alpha: 0.12),
            ),
          ),
          LineChartBarData(
            spots: weightSpots,
            isCurved: true,
            color: AppColors.green,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
    );
  }
}

class _ConsistencyHeatmap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const weeks = 12;
    const daysPerWeek = 7;
    final randomPattern = [
      [1.0, 0.8, 1.0, 0.6, 1.0, 0.9, 0.3],
      [0.9, 1.0, 0.7, 1.0, 0.8, 1.0, 0.5],
      [1.0, 0.6, 0.9, 1.0, 0.4, 0.8, 1.0],
      [0.8, 1.0, 1.0, 0.5, 1.0, 0.7, 0.9],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Consistency', style: context.textTheme.headlineSmall),
            Text(
              '84% active',
              style: context.textTheme.labelMedium?.copyWith(
                color: AppColors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
                  return Expanded(
                    child: Center(
                      child: Text(d, style: context.textTheme.labelSmall),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...List.generate(weeks ~/ 3, (week) {
                final row = randomPattern[week % randomPattern.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: List.generate(daysPerWeek, (day) {
                      final intensity = row[day];
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          height: 22,
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              AppColors.border,
                              AppColors.accent,
                              intensity,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text('Less', style: context.textTheme.labelSmall),
                  const SizedBox(width: AppSpacing.sm),
                  ...List.generate(5, (i) {
                    return Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          AppColors.border,
                          AppColors.accent,
                          i / 4,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                  const SizedBox(width: AppSpacing.sm),
                  Text('More', style: context.textTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 450.ms);
  }
}

class _MuscleBalanceChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const muscles = [
      ('Chest', 0.85, AppColors.accent),
      ('Back', 0.72, AppColors.blue),
      ('Shoulders', 0.90, AppColors.accentSecondary),
      ('Arms', 0.78, AppColors.green),
      ('Legs', 0.65, AppColors.red),
      ('Core', 0.88, AppColors.blue),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Muscle Balance', style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          child: Column(
            children: muscles.map((m) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(m.$1, style: context.textTheme.bodySmall),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: m.$2),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) => LinearProgressIndicator(
                            value: value,
                            backgroundColor: AppColors.border,
                            color: m.$3,
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${(m.$2 * 100).toInt()}%',
                      style: context.textTheme.labelMedium?.copyWith(color: m.$3),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.05, end: 0);
  }
}

class _TransformationGraph extends StatelessWidget {
  const _TransformationGraph({required this.data});

  final List<double> data;

  @override
  Widget build(BuildContext context) {
    final start = data.first;
    final end = data.last;
    final change = end - start;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Transformation', style: context.textTheme.headlineSmall),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: (change <= 0 ? AppColors.green : AppColors.red)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                '${change <= 0 ? '' : '+'}${change.toStringAsFixed(1)} kg',
                style: context.textTheme.labelMedium?.copyWith(
                  color: change <= 0 ? AppColors.green : AppColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SizedBox(
            height: 180,
            child: _MonthlyLineChart(data: data),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TransformStat(label: 'Start', value: '${start.oneDecimal} kg'),
            _TransformStat(label: 'Current', value: '${end.oneDecimal} kg'),
            _TransformStat(
              label: 'Body Fat',
              value: '14.2%',
              color: AppColors.accentSecondary,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 650.ms);
  }
}

class _TransformStat extends StatelessWidget {
  const _TransformStat({
    required this.label,
    required this.value,
    this.color = AppColors.grey,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: context.textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            color: color == AppColors.grey ? AppColors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

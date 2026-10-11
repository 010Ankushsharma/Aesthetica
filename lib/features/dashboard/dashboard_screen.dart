import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/stat_card.dart';
import '../../data/repositories/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final stats = ref.watch(dailyStatsProvider);
    final weeklyCalories = ref.watch(weeklyCaloriesProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Header(profile: profile, stats: stats)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ActivityRingsSection(stats: stats),
                const SizedBox(height: AppSpacing.lg),
                _QuickStatsGrid(stats: stats, profile: profile),
                const SizedBox(height: AppSpacing.lg),
                _TodaysWorkout(),
                const SizedBox(height: AppSpacing.lg),
                _WeeklyChart(data: weeklyCalories),
                const SizedBox(height: AppSpacing.lg),
                _QuickActions(),
                const SizedBox(height: AppSpacing.lg),
                _HealthMetrics(stats: stats, profile: profile),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile, required this.stats});

  final dynamic profile;
  final dynamic stats;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.paddingOf(context).top + AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: context.textTheme.bodyMedium,
                    ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      profile.name.split(' ').first,
                      style: context.textTheme.displaySmall,
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
                  ],
                ),
              ),
              _StreakBadge(streak: profile.streak),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () => context.go('/home/profile'),
                child: Hero(
                  tag: 'avatar',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        profile.name[0],
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                ProgressRing(
                  progress: stats.caloriesProgress,
                  size: 100,
                  lineWidth: 8,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${stats.caloriesBurned}',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('kcal', style: context.textTheme.labelSmall),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Progress',
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _ProgressRow(
                        label: 'Burned',
                        value: '${stats.caloriesBurned}',
                        color: AppColors.accent,
                      ),
                      _ProgressRow(
                        label: 'Remaining',
                        value: '${stats.caloriesRemaining}',
                        color: AppColors.green,
                      ),
                      _ProgressRow(
                        label: 'Goal',
                        value: '${stats.caloriesGoal}',
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: AppColors.accent,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodySmall),
          Text(
            value,
            style: context.textTheme.titleSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _ActivityRingsSection extends StatelessWidget {
  const _ActivityRingsSection({required this.stats});

  final dynamic stats;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          ActivityRings(
            move: stats.moveRing,
            exercise: stats.exerciseRing,
            stand: stats.standRing,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              children: [
                _RingLegend(
                  color: AppColors.red,
                  label: 'Move',
                  value: '${(stats.moveRing * 100).toInt()}%',
                ),
                const SizedBox(height: AppSpacing.sm),
                _RingLegend(
                  color: AppColors.green,
                  label: 'Exercise',
                  value: '${(stats.exerciseRing * 100).toInt()}%',
                ),
                const SizedBox(height: AppSpacing.sm),
                _RingLegend(
                  color: AppColors.blue,
                  label: 'Stand',
                  value: '${(stats.standRing * 100).toInt()}%',
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }
}

class _RingLegend extends StatelessWidget {
  const _RingLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: context.textTheme.bodySmall),
        const Spacer(),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _QuickStatsGrid extends StatelessWidget {
  const _QuickStatsGrid({required this.stats, required this.profile});

  final dynamic stats;
  final dynamic profile;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          label: 'Steps',
          value: stats.steps.formatted,
          unit: '/ ${stats.stepsGoal.formatted}',
          icon: Icons.directions_walk_rounded,
          color: AppColors.blue,
        ),
        StatCard(
          label: 'Heart Rate',
          value: '${stats.heartRate}',
          unit: 'bpm',
          icon: Icons.favorite_rounded,
          color: AppColors.red,
        ),
        StatCard(
          label: 'Water',
          value: '${(stats.waterMl / 1000).oneDecimal}',
          unit: 'L',
          icon: Icons.water_drop_rounded,
          color: AppColors.blue,
          subtitle: '${((stats.waterProgress) * 100).toInt()}% of goal',
        ),
        StatCard(
          label: 'Recovery',
          value: '${stats.recoveryScore}',
          unit: '%',
          icon: Icons.self_improvement_rounded,
          color: AppColors.green,
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _TodaysWorkout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Workout", style: context.textTheme.headlineSmall),
            TextButton(
              onPressed: () => context.go('/home/workouts'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2A1A08), Color(0xFF181818)],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/ai-generator'),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: AppColors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aesthetic Push Day',
                            style: context.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '45 min • 380 kcal • Intermediate',
                            style: context.textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 0.35,
                              backgroundColor: AppColors.border,
                              color: AppColors.accent,
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.play_circle_fill, color: AppColors.accent, size: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05, end: 0);
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.data});

  final List<double> data;

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Weekly Calories', style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 200,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 2500,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.cardElevated,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} kcal',
                      context.textTheme.labelMedium!.copyWith(
                        color: AppColors.white,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(
                      days[value.toInt()],
                      style: context.textTheme.labelSmall,
                    ),
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
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
                                AppColors.accent.withValues(alpha: 0.4),
                                AppColors.accent.withValues(alpha: 0.2),
                              ],
                            ),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.sports_martial_arts, 'Combat', '/combat', AppColors.red),
      (Icons.restaurant_menu, 'Nutrition', '/nutrition', AppColors.green),
      (Icons.people_rounded, 'Social', '/social', AppColors.blue),
      (Icons.auto_awesome, 'AI Plan', '/ai-generator', AppColors.accent),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Explore', style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: actions.map((a) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () {
                    context.hapticLight();
                    context.push(a.$3);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(a.$1, color: a.$4, size: 28),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          a.$2,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms);
  }
}

class _HealthMetrics extends StatelessWidget {
  const _HealthMetrics({required this.stats, required this.profile});

  final dynamic stats;
  final dynamic profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Body Metrics', style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'BMI',
                value: profile.bmi.toStringAsFixed(1),
                icon: Icons.monitor_weight_outlined,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                label: 'Body Fat',
                value: '${profile.bodyFatPercent}',
                unit: '%',
                icon: Icons.pie_chart_outline_rounded,
                color: AppColors.accentSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Sleep Score',
                value: '${stats.sleepScore}',
                unit: '%',
                icon: Icons.bedtime_rounded,
                color: AppColors.blue,
                subtitle: '${stats.sleepHours}h last night',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                label: 'Weight',
                value: '${profile.weightKg}',
                unit: 'kg',
                icon: Icons.scale_rounded,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 800.ms);
  }
}

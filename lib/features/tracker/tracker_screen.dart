import 'package:aesthetica/core/constants/app_colors.dart';
import 'package:aesthetica/core/constants/app_spacing.dart';
import 'package:aesthetica/core/utils/extensions.dart';
import 'package:aesthetica/core/widgets/glass_card.dart';
import 'package:aesthetica/core/widgets/gradient_button.dart';
import 'package:aesthetica/core/widgets/progress_ring.dart';
import 'package:aesthetica/core/widgets/stat_card.dart';
import 'package:aesthetica/data/models/models.dart';
import 'package:aesthetica/data/repositories/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final stats = ref.watch(dailyStatsProvider);
    final measurements = ref.watch(measurementsProvider);
    final userState = ref.watch(userNotifierProvider);

    return _TrackerBody(
      profile: profile,
      stats: stats,
      initialMeasurements: measurements,
      initialMood: userState.mood,
      initialEnergy: userState.energy,
      onSave: (data) async {
        await ref.read(userNotifierProvider.notifier).saveTrackerLog(
              waterMl: data.waterMl,
              recovery: data.recovery,
              mood: data.mood,
              energy: data.energy,
              measurements: data.measurements,
            );
      },
    );
  }
}

class _TrackerSaveData {
  const _TrackerSaveData({
    required this.waterMl,
    required this.recovery,
    required this.mood,
    required this.energy,
    required this.measurements,
  });

  final double waterMl;
  final double recovery;
  final double mood;
  final double energy;
  final Map<String, double> measurements;
}

class _TrackerBody extends StatefulWidget {
  const _TrackerBody({
    required this.profile,
    required this.stats,
    required this.initialMeasurements,
    required this.initialMood,
    required this.initialEnergy,
    required this.onSave,
  });

  final UserProfile profile;
  final DailyStats stats;
  final Map<String, double> initialMeasurements;
  final double initialMood;
  final double initialEnergy;
  final Future<void> Function(_TrackerSaveData data) onSave;

  @override
  State<_TrackerBody> createState() => _TrackerBodyState();
}

class _TrackerBodyState extends State<_TrackerBody> {
  late double _waterMl;
  double _mood = 4;
  double _energy = 3.5;
  late double _recovery;

  late Map<String, double> _measurements;

  @override
  void initState() {
    super.initState();
    _waterMl = widget.stats.waterMl.toDouble();
    _recovery = widget.stats.recoveryScore.toDouble();
    _mood = widget.initialMood;
    _energy = widget.initialEnergy;
    _measurements = Map<String, double>.from(widget.initialMeasurements);
  }

  @override
  void didUpdateWidget(covariant _TrackerBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stats.waterMl != widget.stats.waterMl) {
      _waterMl = widget.stats.waterMl.toDouble();
    }
    if (oldWidget.stats.recoveryScore != widget.stats.recoveryScore) {
      _recovery = widget.stats.recoveryScore.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final stats = widget.stats;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Header()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _CaloriesSection(stats: stats),
                const SizedBox(height: AppSpacing.lg),
                _BodyMetricsSection(profile: profile),
                const SizedBox(height: AppSpacing.lg),
                _MeasurementsSection(measurements: _measurements),
                const SizedBox(height: AppSpacing.lg),
                _WaterSection(
                  waterMl: _waterMl,
                  goalMl: stats.waterGoalMl.toDouble(),
                  onChanged: (v) => setState(() => _waterMl = v),
                ),
                const SizedBox(height: AppSpacing.lg),
                _WellnessSection(
                  stats: stats,
                  mood: _mood,
                  energy: _energy,
                  recovery: _recovery,
                  onMoodChanged: (v) => setState(() => _mood = v),
                  onEnergyChanged: (v) => setState(() => _energy = v),
                  onRecoveryChanged: (v) => setState(() => _recovery = v),
                ),
                const SizedBox(height: AppSpacing.lg),
                GradientButton(
                  label: 'Save Today\'s Log',
                  icon: Icons.check_rounded,
                  onPressed: () async {
                    context.hapticMedium();
                    await widget.onSave(
                      _TrackerSaveData(
                        waterMl: _waterMl,
                        recovery: _recovery,
                        mood: _mood,
                        energy: _energy,
                        measurements: _measurements,
                      ),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Tracker updated successfully'),
                        backgroundColor: AppColors.cardElevated,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
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
            'Body Tracker',
            style: context.textTheme.displaySmall,
          ).animate().fadeIn().slideX(begin: -0.1, end: 0),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Log metrics & monitor progress',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
        ],
      ),
    );
  }
}

class _CaloriesSection extends StatelessWidget {
  const _CaloriesSection({required this.stats});

  final DailyStats stats;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calories', style: context.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              ProgressRing(
                progress: stats.caloriesProgress,
                size: 110,
                lineWidth: 9,
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
                  children: [
                    _InputCard(
                      label: 'Burned',
                      value: '${stats.caloriesBurned}',
                      unit: 'kcal',
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InputCard(
                      label: 'Remaining',
                      value: '${stats.caloriesRemaining}',
                      unit: 'kcal',
                      icon: Icons.battery_charging_full_rounded,
                      color: AppColors.green,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InputCard(
                      label: 'Goal',
                      value: '${stats.caloriesGoal}',
                      unit: 'kcal',
                      icon: Icons.flag_rounded,
                      color: AppColors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.08, end: 0);
  }
}

class _BodyMetricsSection extends StatelessWidget {
  const _BodyMetricsSection({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Body Metrics', style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.45,
          children: [
            StatCard(
              label: 'Weight',
              value: '${profile.weightKg}',
              unit: 'kg',
              icon: Icons.scale_rounded,
              color: AppColors.green,
            ),
            StatCard(
              label: 'BMI',
              value: profile.bmi.toStringAsFixed(1),
              icon: Icons.monitor_weight_outlined,
              color: AppColors.accent,
              subtitle: _bmiLabel(profile.bmi),
            ),
            StatCard(
              label: 'Body Fat',
              value: '${profile.bodyFatPercent}',
              unit: '%',
              icon: Icons.pie_chart_outline_rounded,
              color: AppColors.accentSecondary,
            ),
            StatCard(
              label: 'Height',
              value: '${profile.heightCm.toInt()}',
              unit: 'cm',
              icon: Icons.height_rounded,
              color: AppColors.blue,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 250.ms);
  }

  String _bmiLabel(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}

class _MeasurementsSection extends StatelessWidget {
  const _MeasurementsSection({required this.measurements});

  final Map<String, double> measurements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Measurements', style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          child: Column(
            children: measurements.entries.map((entry) {
              final isLast = entry.key == measurements.keys.last;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
                child: _InputCard(
                  label: entry.key,
                  value: entry.value.oneDecimal,
                  unit: 'cm',
                  icon: _measurementIcon(entry.key),
                  color: AppColors.accent,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05, end: 0);
  }

  IconData _measurementIcon(String label) => switch (label) {
        'Chest' => Icons.fitness_center_rounded,
        'Waist' => Icons.straighten_rounded,
        'Shoulders' => Icons.accessibility_new_rounded,
        'Arms' => Icons.sports_gymnastics_rounded,
        'Thighs' => Icons.directions_run_rounded,
        'Neck' => Icons.face_rounded,
        _ => Icons.straighten_rounded,
      };
}

class _WaterSection extends StatelessWidget {
  const _WaterSection({
    required this.waterMl,
    required this.goalMl,
    required this.onChanged,
  });

  final double waterMl;
  final double goalMl;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final progress = (waterMl / goalMl).clamp(0.0, 1.0);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: AppColors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Water Intake', style: context.textTheme.titleLarge),
              ),
              Text(
                '${(waterMl / 1000).oneDecimal} L',
                style: context.textTheme.titleMedium?.copyWith(
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProgressRing(
                progress: progress,
                size: 100,
                lineWidth: 8,
                color: AppColors.blue,
                center: Text(
                  '${(progress * 100).toInt()}%',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.blue,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.blue,
              overlayColor: AppColors.blue.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: waterMl,
              min: 0,
              max: goalMl,
              divisions: (goalMl / 100).toInt(),
              onChanged: (v) {
                context.hapticSelection();
                onChanged(v);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 L', style: context.textTheme.labelSmall),
              Text(
                'Goal: ${(goalMl / 1000).oneDecimal} L',
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.05, end: 0);
  }
}

class _WellnessSection extends StatelessWidget {
  const _WellnessSection({
    required this.stats,
    required this.mood,
    required this.energy,
    required this.recovery,
    required this.onMoodChanged,
    required this.onEnergyChanged,
    required this.onRecoveryChanged,
  });

  final DailyStats stats;
  final double mood;
  final double energy;
  final double recovery;
  final ValueChanged<double> onMoodChanged;
  final ValueChanged<double> onEnergyChanged;
  final ValueChanged<double> onRecoveryChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wellness', style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          child: Column(
            children: [
              _WellnessSlider(
                label: 'Sleep',
                value: stats.sleepHours,
                max: 12,
                unit: 'h',
                icon: Icons.bedtime_rounded,
                color: AppColors.blue,
                displayValue: '${stats.sleepHours.oneDecimal}h',
                readOnly: true,
              ),
              const Divider(color: AppColors.border, height: AppSpacing.lg),
              _WellnessSlider(
                label: 'Mood',
                value: mood,
                max: 5,
                unit: '',
                icon: Icons.sentiment_satisfied_alt_rounded,
                color: AppColors.accentSecondary,
                displayValue: _moodLabel(mood),
                onChanged: onMoodChanged,
              ),
              const Divider(color: AppColors.border, height: AppSpacing.lg),
              _WellnessSlider(
                label: 'Energy',
                value: energy,
                max: 5,
                unit: '',
                icon: Icons.bolt_rounded,
                color: AppColors.accent,
                displayValue: _energyLabel(energy),
                onChanged: onEnergyChanged,
              ),
              const Divider(color: AppColors.border, height: AppSpacing.lg),
              _WellnessSlider(
                label: 'Recovery',
                value: recovery,
                max: 100,
                unit: '%',
                icon: Icons.self_improvement_rounded,
                color: AppColors.green,
                displayValue: '${recovery.toInt()}%',
                onChanged: onRecoveryChanged,
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 550.ms);
  }

  String _moodLabel(double v) {
    if (v >= 4.5) return 'Great';
    if (v >= 3.5) return 'Good';
    if (v >= 2.5) return 'Okay';
    if (v >= 1.5) return 'Low';
    return 'Poor';
  }

  String _energyLabel(double v) {
    if (v >= 4.5) return 'Peak';
    if (v >= 3.5) return 'High';
    if (v >= 2.5) return 'Moderate';
    if (v >= 1.5) return 'Low';
    return 'Drained';
  }
}

class _WellnessSlider extends StatelessWidget {
  const _WellnessSlider({
    required this.label,
    required this.value,
    required this.max,
    required this.unit,
    required this.icon,
    required this.color,
    required this.displayValue,
    this.onChanged,
    this.readOnly = false,
  });

  final String label;
  final double value;
  final double max;
  final String unit;
  final IconData icon;
  final Color color;
  final String displayValue;
  final ValueChanged<double>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: context.textTheme.titleSmall),
            const Spacer(),
            Text(
              displayValue,
              style: context.textTheme.titleSmall?.copyWith(color: color),
            ),
          ],
        ),
        if (!readOnly) ...[
          const SizedBox(height: AppSpacing.xs),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: AppColors.border,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              trackHeight: 5,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: max,
              divisions: max.toInt(),
              onChanged: (v) {
                context.hapticSelection();
                onChanged?.call(v);
              },
            ),
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / max).clamp(0.0, 1.0),
              backgroundColor: AppColors.border,
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label, style: context.textTheme.bodySmall),
          ),
          Text(
            value,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (unit.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(unit, style: context.textTheme.labelSmall),
          ],
        ],
      ),
    );
  }
}

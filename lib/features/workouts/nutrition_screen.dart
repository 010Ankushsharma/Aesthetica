import 'package:aesthetica/core/constants/app_colors.dart';
import 'package:aesthetica/core/constants/app_spacing.dart';
import 'package:aesthetica/core/utils/extensions.dart';
import 'package:aesthetica/core/widgets/glass_card.dart';
import 'package:aesthetica/core/widgets/progress_ring.dart';
import 'package:aesthetica/core/widgets/stat_card.dart';
import 'package:aesthetica/data/repositories/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _nutritionActivityProvider = StateProvider<double>((ref) => 1.55);

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final stats = ref.watch(dailyStatsProvider);
    final activityFactor = ref.watch(_nutritionActivityProvider);

    final bmr = _calculateBmr(
      age: profile.age,
      gender: profile.gender,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
    );
    final tdee = (bmr * activityFactor).round();
    final macros = _calculateMacros(tdee, profile.weightKg);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _Header(onBack: () => context.pop()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _CalculatorSection(
                  bmr: bmr,
                  tdee: tdee,
                  activityFactor: activityFactor,
                  onActivityChanged: (v) => ref
                      .read(_nutritionActivityProvider.notifier)
                      .state = v,
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.lg),
                _MacrosSection(macros: macros)
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.lg),
                _WaterTracker(stats: stats)
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.lg),
                _MealSuggestions(tdee: tdee)
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.05, end: 0),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

double _calculateBmr({
  required int age,
  required String gender,
  required double heightCm,
  required double weightKg,
}) {
  final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
  return gender.toLowerCase() == 'female' ? base - 161 : base + 5;
}

class _MacroTargets {
  const _MacroTargets({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
  });

  final int protein;
  final int carbs;
  final int fat;
  final int calories;
}

_MacroTargets _calculateMacros(int tdee, double weightKg) {
  final protein = (weightKg * 2).round();
  final proteinCal = protein * 4;
  final fatCal = (tdee * 0.25).round();
  final fat = (fatCal / 9).round();
  final carbs = ((tdee - proteinCal - fatCal) / 4).round();
  return _MacroTargets(
    protein: protein,
    carbs: carbs,
    fat: fat,
    calories: tdee,
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.paddingOf(context).top + AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.green.withValues(alpha: 0.2),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.card.withValues(alpha: 0.6),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppColors.green,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrition',
                      style: context.textTheme.displaySmall,
                    ).animate().fadeIn().slideX(begin: -0.05, end: 0),
                    Text(
                      'Fuel your aesthetic physique',
                      style: context.textTheme.bodySmall,
                    ).animate().fadeIn(delay: 80.ms),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalculatorSection extends StatelessWidget {
  const _CalculatorSection({
    required this.bmr,
    required this.tdee,
    required this.activityFactor,
    required this.onActivityChanged,
  });

  final double bmr;
  final int tdee;
  final double activityFactor;
  final ValueChanged<double> onActivityChanged;

  static const _activityLevels = [
    (1.2, 'Sedentary'),
    (1.375, 'Light'),
    (1.55, 'Moderate'),
    (1.725, 'Active'),
    (1.9, 'Very Active'),
  ];

  static String _activityLabel(double factor) {
    for (final (value, label) in _activityLevels) {
      if ((factor - value).abs() < 0.01) return label;
    }
    return 'Moderate';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined, color: AppColors.green),
              const SizedBox(width: AppSpacing.sm),
              Text('BMR & TDEE', style: context.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'BMR',
                  value: bmr.round().toString(),
                  unit: 'kcal',
                  icon: Icons.bedtime_outlined,
                  color: AppColors.blue,
                  subtitle: 'Basal metabolic rate',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatCard(
                  label: 'TDEE',
                  value: '$tdee',
                  unit: 'kcal',
                  icon: Icons.bolt_rounded,
                  color: AppColors.green,
                  subtitle: 'Daily energy expenditure',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Activity Level',
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: activityFactor,
            min: 1.2,
            max: 1.9,
            divisions: 4,
            activeColor: AppColors.green,
            label: _activityLabel(activityFactor),
            onChanged: onActivityChanged,
          ),
          Center(
            child: Text(
              _activityLabel(activityFactor),
              style: context.textTheme.titleSmall?.copyWith(
                color: AppColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacrosSection extends StatelessWidget {
  const _MacrosSection({required this.macros});

  final _MacroTargets macros;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily Macros', style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          child: Row(
            children: [
              Expanded(
                child: _MacroRing(
                  label: 'Protein',
                  grams: macros.protein,
                  color: AppColors.red,
                  percent: macros.protein * 4 / macros.calories,
                ),
              ),
              Expanded(
                child: _MacroRing(
                  label: 'Carbs',
                  grams: macros.carbs,
                  color: AppColors.accent,
                  percent: macros.carbs * 4 / macros.calories,
                ),
              ),
              Expanded(
                child: _MacroRing(
                  label: 'Fat',
                  grams: macros.fat,
                  color: AppColors.blue,
                  percent: macros.fat * 9 / macros.calories,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroRing extends StatelessWidget {
  const _MacroRing({
    required this.label,
    required this.grams,
    required this.color,
    required this.percent,
  });

  final String label;
  final int grams;
  final Color color;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return ProgressRing(
      progress: percent.clamp(0.0, 1.0),
      size: 80,
      lineWidth: 6,
      color: color,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$grams',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('g', style: context.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _WaterTracker extends ConsumerWidget {
  const _WaterTracker({required this.stats});

  final dynamic stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Water Intake', style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          child: Row(
            children: [
              ProgressRing(
                progress: stats.waterProgress,
                size: 100,
                lineWidth: 8,
                color: AppColors.blue,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(stats.waterMl / 1000).oneDecimal}',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('L', style: context.textTheme.labelSmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.waterMl} / ${stats.waterGoalMl} ml',
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: stats.waterProgress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        color: AppColors.blue,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _WaterButton(
                          label: '+250ml',
                          onTap: () => context.hapticLight(),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _WaterButton(
                          label: '+500ml',
                          onTap: () => context.hapticLight(),
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
    );
  }
}

class _WaterButton extends StatelessWidget {
  const _WaterButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(color: AppColors.blue),
        ),
      ),
    );
  }
}

class _MealSuggestions extends StatelessWidget {
  const _MealSuggestions({required this.tdee});

  final int tdee;

  @override
  Widget build(BuildContext context) {
    final meals = [
      _Meal(
        name: 'Power Breakfast',
        calories: (tdee * 0.25).round(),
        description: 'Greek yogurt, oats, berries & almonds',
        icon: Icons.wb_sunny_outlined,
        color: AppColors.accent,
      ),
      _Meal(
        name: 'Lean Lunch',
        calories: (tdee * 0.35).round(),
        description: 'Grilled chicken, quinoa & roasted vegetables',
        icon: Icons.lunch_dining_outlined,
        color: AppColors.green,
      ),
      _Meal(
        name: 'Recovery Dinner',
        calories: (tdee * 0.30).round(),
        description: 'Salmon, sweet potato & asparagus',
        icon: Icons.nights_stay_outlined,
        color: AppColors.blue,
      ),
      _Meal(
        name: 'Pre-Workout Snack',
        calories: (tdee * 0.10).round(),
        description: 'Banana, peanut butter & protein shake',
        icon: Icons.fitness_center_outlined,
        color: AppColors.accentSecondary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Meal Suggestions', style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        ...meals.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GlassCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: m.color.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(m.icon, color: m.color, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                m.name,
                                style: context.textTheme.titleSmall,
                              ),
                            ),
                            Text(
                              '${m.calories} kcal',
                              style: context.textTheme.labelMedium?.copyWith(
                                color: m.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.description,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.grey,
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
      ],
    );
  }
}

class _Meal {
  const _Meal({
    required this.name,
    required this.calories,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String name;
  final int calories;
  final String description;
  final IconData icon;
  final Color color;
}

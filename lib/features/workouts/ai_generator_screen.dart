import 'package:aesthetica/core/constants/app_colors.dart';
import 'package:aesthetica/core/constants/app_spacing.dart';
import 'package:aesthetica/core/router/app_router.dart';
import 'package:aesthetica/core/services/ai_workout_service.dart';
import 'package:aesthetica/core/utils/extensions.dart';
import 'package:aesthetica/core/widgets/glass_card.dart';
import 'package:aesthetica/core/widgets/gradient_button.dart';
import 'package:aesthetica/data/models/models.dart';
import 'package:aesthetica/data/repositories/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AiGeneratorScreen extends ConsumerStatefulWidget {
  const AiGeneratorScreen({super.key});

  @override
  ConsumerState<AiGeneratorScreen> createState() => _AiGeneratorScreenState();
}

class _AiGeneratorScreenState extends ConsumerState<AiGeneratorScreen> {
  late int _age;
  late String _gender;
  late double _heightCm;
  late double _weightKg;
  late Difficulty _experience;
  final Set<WorkoutGoal> _goals = {};
  double _timeMinutes = 45;
  final Set<String> _equipment = {'Bodyweight'};

  bool _isGenerating = false;
  List<Exercise>? _generatedPlan;

  static const _equipmentOptions = [
    'Bodyweight',
    'Dumbbells',
    'Barbell',
    'Resistance Bands',
    'Pull-up Bar',
    'Kettlebell',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _age = profile.age;
    _gender = profile.gender;
    _heightCm = profile.heightCm;
    _weightKg = profile.weightKg;
    _experience = profile.experience;
    _goals.addAll(profile.goals);
  }

  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _generatedPlan = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    final plan = AiWorkoutService().generate(
      age: _age,
      gender: _gender,
      heightCm: _heightCm,
      weightKg: _weightKg,
      experience: _experience,
      goals: _goals,
      timeMinutes: _timeMinutes,
      equipment: _equipment,
    );

    if (mounted) {
      setState(() {
        _generatedPlan = plan;
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Header(onClose: () => context.pop())),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _FormSection(
                  title: 'About You',
                  icon: Icons.person_outline_rounded,
                  child: Column(
                    children: [
                      _NumberField(
                        label: 'Age',
                        value: _age.toDouble(),
                        min: 16,
                        max: 80,
                        unit: 'yrs',
                        onChanged: (v) => setState(() => _age = v.round()),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _GenderSelector(
                        value: _gender,
                        onChanged: (g) => setState(() => _gender = g),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _NumberField(
                        label: 'Height',
                        value: _heightCm,
                        min: 140,
                        max: 220,
                        unit: 'cm',
                        onChanged: (v) => setState(() => _heightCm = v),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _NumberField(
                        label: 'Weight',
                        value: _weightKg,
                        min: 40,
                        max: 200,
                        unit: 'kg',
                        onChanged: (v) => setState(() => _weightKg = v),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.md),
                _FormSection(
                  title: 'Experience',
                  icon: Icons.trending_up_rounded,
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: Difficulty.values.map((d) {
                      final selected = _experience == d;
                      return _SelectableChip(
                        label: d == Difficulty.beginner
                            ? 'Beginner'
                            : d == Difficulty.intermediate
                                ? 'Intermediate'
                                : 'Advanced',
                        isSelected: selected,
                        onTap: () => setState(() => _experience = d),
                      );
                    }).toList(),
                  ),
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.md),
                _FormSection(
                  title: 'Goals',
                  icon: Icons.flag_outlined,
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: WorkoutGoal.values.map((g) {
                      return _SelectableChip(
                        label: _goalLabel(g),
                        isSelected: _goals.contains(g),
                        onTap: () => setState(() {
                          if (_goals.contains(g)) {
                            _goals.remove(g);
                          } else {
                            _goals.add(g);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.md),
                _FormSection(
                  title: 'Session Length',
                  icon: Icons.schedule_rounded,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_timeMinutes.round()} minutes',
                            style: context.textTheme.titleMedium?.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                          Text(
                            'Recommended: 30–60 min',
                            style: context.textTheme.labelSmall,
                          ),
                        ],
                      ),
                      Slider(
                        value: _timeMinutes,
                        min: 15,
                        max: 90,
                        divisions: 15,
                        activeColor: AppColors.accent,
                        onChanged: (v) => setState(() => _timeMinutes = v),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.md),
                _FormSection(
                  title: 'Equipment',
                  icon: Icons.build_outlined,
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _equipmentOptions.map((eq) {
                      return _SelectableChip(
                        label: eq,
                        isSelected: _equipment.contains(eq),
                        onTap: () => setState(() {
                          if (_equipment.contains(eq)) {
                            if (_equipment.length > 1) _equipment.remove(eq);
                          } else {
                            _equipment.add(eq);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.lg),
                GradientButton(
                  label: 'Generate Workout',
                  icon: Icons.auto_awesome_rounded,
                  isLoading: _isGenerating,
                  onPressed: _isGenerating ? null : _generate,
                ),
                if (_generatedPlan != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _GeneratedPlanSection(
                    exercises: _generatedPlan!,
                    timeMinutes: _timeMinutes.round(),
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.paddingOf(context).top + AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.card.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Workout Generator',
                      style: context.textTheme.headlineMedium,
                    ),
                    Text(
                      'Personalized to your physique goals',
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.05, end: 0),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: context.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: context.textTheme.bodyLarge),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              _StepButton(
                icon: Icons.remove,
                onTap: value > min ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: Text(
                  '${value.round()} $unit',
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium,
                ),
              ),
              _StepButton(
                icon: Icons.add,
                onTap: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.cardElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppColors.white : AppColors.greyDark,
        ),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text('Gender', style: context.textTheme.bodyLarge),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: ['Male', 'Female'].map((g) {
              final selected = value == g;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: g == 'Male' ? AppSpacing.sm : 0),
                  child: _SelectableChip(
                    label: g,
                    isSelected: selected,
                    onTap: () => onChanged(g),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.hapticSelection();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.accentGradient : null,
          color: isSelected ? null : AppColors.cardElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: isSelected ? AppColors.white : AppColors.grey,
          ),
        ),
      ),
    );
  }
}

class _GeneratedPlanSection extends StatelessWidget {
  const _GeneratedPlanSection({
    required this.exercises,
    required this.timeMinutes,
  });

  final List<Exercise> exercises;
  final int timeMinutes;

  @override
  Widget build(BuildContext context) {
    final totalCalories = exercises
        .map((e) => e.caloriesPerMinute * e.durationMinutes)
        .fold<double>(0, (a, b) => a + b)
        .round();

    return GlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accent.withValues(alpha: 0.15),
          AppColors.card.withValues(alpha: 0.6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.green),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Your AI Workout Plan',
                style: context.textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$timeMinutes min • $totalCalories kcal • ${exercises.length} exercises',
            style: context.textTheme.bodySmall?.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: AppSpacing.md),
          ...exercises.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: context.textTheme.labelMedium?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.value.name,
                              style: context.textTheme.titleSmall,
                            ),
                            Text(
                              '${e.value.sets} × ${e.value.reps} • ${e.value.durationMinutes} min',
                              style: context.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: 'Start Workout',
            icon: Icons.play_arrow_rounded,
            width: double.infinity,
            onPressed: () {
              context.hapticMedium();
              startWorkoutSession(
                context,
                exerciseIds: exercises.map((e) => e.id).toList(),
                title: 'AI Workout Plan',
              );
            },
          ),
        ],
      ),
    );
  }
}

String _goalLabel(WorkoutGoal g) {
  return switch (g) {
    WorkoutGoal.vTaper => 'V-Taper',
    WorkoutGoal.wideShoulders => 'Wide Shoulders',
    WorkoutGoal.biggerChest => 'Bigger Chest',
    WorkoutGoal.largerArms => 'Larger Arms',
    WorkoutGoal.visibleAbs => 'Visible Abs',
    WorkoutGoal.leanLegs => 'Lean Legs',
    WorkoutGoal.athleticBuild => 'Athletic',
    WorkoutGoal.calisthenics => 'Calisthenics',
    WorkoutGoal.streetWorkout => 'Street Workout',
    WorkoutGoal.summerBody => 'Summer Body',
    WorkoutGoal.beginnerTransformation => 'Beginner',
    WorkoutGoal.transformation90 => '90-Day',
    WorkoutGoal.transformation180 => '180-Day',
    WorkoutGoal.transformation365 => '365-Day',
    WorkoutGoal.combatFitness => 'Combat',
    WorkoutGoal.fatLoss => 'Fat Loss',
    WorkoutGoal.muscleGain => 'Muscle Gain',
  };
}

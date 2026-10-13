import 'package:aesthetica/core/constants/app_colors.dart';
import 'package:aesthetica/core/constants/app_spacing.dart';
import 'package:aesthetica/core/router/app_router.dart';
import 'package:aesthetica/core/utils/extensions.dart';
import 'package:aesthetica/core/widgets/glass_card.dart';
import 'package:aesthetica/core/widgets/gradient_button.dart';
import 'package:aesthetica/core/widgets/stat_card.dart';
import 'package:aesthetica/data/models/models.dart';
import 'package:aesthetica/data/repositories/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise =
        ref.watch(exerciseRepositoryProvider).getById(exerciseId);

    if (exercise == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            'Exercise not found',
            style: context.textTheme.titleLarge,
          ),
        ),
      );
    }

    final calories =
        (exercise.caloriesPerMinute * exercise.durationMinutes).round();
    final difficultyColor = _difficultyColor(exercise.difficulty);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Hero(
              tag: 'exercise-${exercise.id}',
              child: Material(
                color: Colors.transparent,
                child: _GradientHeader(
                  exercise: exercise,
                  difficultyColor: difficultyColor,
                  onBack: () => context.pop(),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xxl + 80,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Sets × Reps',
                        value: '${exercise.sets}',
                        unit: '× ${exercise.reps}',
                        icon: Icons.repeat_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatCard(
                        label: 'Calories',
                        value: '$calories',
                        unit: 'kcal',
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Duration',
                        value: '${exercise.durationMinutes}',
                        unit: 'min',
                        icon: Icons.timer_outlined,
                        color: AppColors.blue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatCard(
                        label: 'Rest',
                        value: '${exercise.restSeconds}',
                        unit: 'sec',
                        icon: Icons.pause_circle_outline_rounded,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.lg),
                _SectionTitle(title: 'Target Muscles', icon: Icons.fitness_center),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: exercise.targetMuscles
                      .map(
                        (m) => _TagChip(
                          label: _muscleLabel(m),
                          color: AppColors.accent,
                        ),
                      )
                      .toList(),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: AppSpacing.lg),
                _DetailSection(
                  title: 'Instructions',
                  icon: Icons.list_alt_rounded,
                  items: exercise.instructions,
                  bulletColor: AppColors.green,
                  delay: 250,
                ),
                const SizedBox(height: AppSpacing.lg),
                _DetailSection(
                  title: 'Common Mistakes',
                  icon: Icons.warning_amber_rounded,
                  items: exercise.commonMistakes,
                  bulletColor: AppColors.red,
                  delay: 300,
                ),
                const SizedBox(height: AppSpacing.lg),
                _DetailSection(
                  title: 'Pro Tips',
                  icon: Icons.lightbulb_outline_rounded,
                  items: exercise.tips,
                  bulletColor: AppColors.accentSecondary,
                  delay: 350,
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: GradientButton(
            label: 'Start Workout',
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              context.hapticMedium();
              startWorkoutSession(
                context,
                exerciseIds: [exercise.id],
                title: exercise.name,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({
    required this.exercise,
    required this.difficultyColor,
    required this.onBack,
  });

  final Exercise exercise;
  final Color difficultyColor;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.paddingOf(context).top + AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            difficultyColor.withValues(alpha: 0.35),
            const Color(0xFF1A1208),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.card.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: difficultyColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  exercise.difficultyLabel,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: difficultyColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            exercise.name,
            style: context.textTheme.displaySmall,
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          const SizedBox(height: AppSpacing.sm),
          Text(
            exercise.categoryLabel,
            style: context.textTheme.bodyLarge?.copyWith(color: AppColors.grey),
          ).animate().fadeIn(delay: 80.ms),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: context.textTheme.headlineSmall),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.bulletColor,
    required this.delay,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final Color bulletColor;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: bulletColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: context.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 7),
                        decoration: BoxDecoration(
                          color: bulletColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          e.value,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.05, end: 0);
  }
}

String _muscleLabel(MuscleGroup m) {
  return switch (m) {
    MuscleGroup.chest => 'Chest',
    MuscleGroup.back => 'Back',
    MuscleGroup.shoulders => 'Shoulders',
    MuscleGroup.biceps => 'Biceps',
    MuscleGroup.triceps => 'Triceps',
    MuscleGroup.forearms => 'Forearms',
    MuscleGroup.abs => 'Abs',
    MuscleGroup.obliques => 'Obliques',
    MuscleGroup.quads => 'Quads',
    MuscleGroup.hamstrings => 'Hamstrings',
    MuscleGroup.glutes => 'Glutes',
    MuscleGroup.calves => 'Calves',
    MuscleGroup.core => 'Core',
    MuscleGroup.fullBody => 'Full Body',
    MuscleGroup.cardio => 'Cardio',
  };
}

Color _difficultyColor(Difficulty d) {
  return switch (d) {
    Difficulty.beginner => AppColors.green,
    Difficulty.intermediate => AppColors.accent,
    Difficulty.advanced => AppColors.red,
  };
}

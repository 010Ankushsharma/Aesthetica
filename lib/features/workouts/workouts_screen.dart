import 'package:aesthetica/core/constants/app_colors.dart';
import 'package:aesthetica/core/constants/app_spacing.dart';
import 'package:aesthetica/core/utils/extensions.dart';
import 'package:aesthetica/core/widgets/glass_card.dart';
import 'package:aesthetica/data/models/models.dart';
import 'package:aesthetica/data/repositories/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _workoutsSearchProvider = StateProvider<String>((ref) => '');
final _workoutsCategoryProvider =
    StateProvider<ExerciseCategory?>((ref) => null);

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(_workoutsSearchProvider);
    final category = ref.watch(_workoutsCategoryProvider);
    final exercises = ref.watch(exercisesProvider);

    final filtered = exercises.where((e) {
      final matchesCategory = category == null || e.category == category;
      final query = search.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          e.name.toLowerCase().contains(query) ||
          e.categoryLabel.toLowerCase().contains(query) ||
          e.targetMuscles.any(
            (m) => _muscleLabel(m).toLowerCase().contains(query),
          );
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Header(exerciseCount: exercises.length)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: _SearchBar(
                value: search,
                onChanged: (v) =>
                    ref.read(_workoutsSearchProvider.notifier).state = v,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),
            ),
          ),
          SliverToBoxAdapter(
            child: _CategoryChips(
              selected: category,
              onSelected: (c) =>
                  ref.read(_workoutsCategoryProvider.notifier).state = c,
            ),
          ),
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: AppColors.grey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No exercises found',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                100,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exercise = filtered[index];
                    return _ExerciseCard(
                      exercise: exercise,
                      index: index,
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.exerciseCount});

  final int exerciseCount;

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
            'Workouts',
            style: context.textTheme.displaySmall,
          ).animate().fadeIn().slideX(begin: -0.1, end: 0),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$exerciseCount exercises • Train smarter',
            style: context.textTheme.bodyMedium?.copyWith(color: AppColors.grey),
          ).animate().fadeIn(delay: 80.ms).slideX(begin: -0.1, end: 0),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.grey, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: context.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search exercises, muscles...',
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.greyDark,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (value.isNotEmpty)
            GestureDetector(
              onTap: () => onChanged(''),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.grey,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final ExerciseCategory? selected;
  final ValueChanged<ExerciseCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          _Chip(
            label: 'All',
            isSelected: selected == null,
            onTap: () {
              context.hapticSelection();
              onSelected(null);
            },
          ),
          ...ExerciseCategory.values.map(
            (c) => _Chip(
              label: _categoryShortLabel(c),
              isSelected: selected == c,
              onTap: () {
                context.hapticSelection();
                onSelected(c);
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.accentGradient : null,
            color: isSelected ? null : AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.index});

  final Exercise exercise;
  final int index;

  @override
  Widget build(BuildContext context) {
    final difficultyColor = _difficultyColor(exercise.difficulty);

    return GestureDetector(
      onTap: () {
        context.hapticLight();
        context.push('/exercise/${exercise.id}');
      },
      child: Hero(
        tag: 'exercise-${exercise.id}',
        child: Material(
          color: Colors.transparent,
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        difficultyColor.withValues(alpha: 0.25),
                        AppColors.cardElevated,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    _muscleIcon(exercise.targetMuscles.first),
                    color: difficultyColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  exercise.name,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyColor.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        exercise.difficultyLabel,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: difficultyColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${exercise.durationMinutes}m',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (80 + index * 40).ms)
        .slideY(begin: 0.08, end: 0);
  }
}

String _categoryShortLabel(ExerciseCategory c) {
  return switch (c) {
    ExerciseCategory.beginner => 'Beginner',
    ExerciseCategory.intermediate => 'Intermed.',
    ExerciseCategory.advanced => 'Advanced',
    ExerciseCategory.fatLoss => 'Fat Loss',
    ExerciseCategory.muscleGain => 'Muscle',
    ExerciseCategory.aestheticPhysique => 'Aesthetic',
    ExerciseCategory.mobility => 'Mobility',
    ExerciseCategory.stretching => 'Stretch',
    ExerciseCategory.flexibility => 'Flex',
    ExerciseCategory.warmup => 'Warmup',
    ExerciseCategory.cooldown => 'Cooldown',
    ExerciseCategory.recovery => 'Recovery',
  };
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

IconData _muscleIcon(MuscleGroup m) {
  return switch (m) {
    MuscleGroup.chest => Icons.fitness_center_rounded,
    MuscleGroup.back => Icons.accessibility_new_rounded,
    MuscleGroup.shoulders => Icons.sports_gymnastics_rounded,
    MuscleGroup.biceps || MuscleGroup.triceps || MuscleGroup.forearms =>
      Icons.fitness_center_rounded,
    MuscleGroup.abs || MuscleGroup.obliques || MuscleGroup.core =>
      Icons.self_improvement_rounded,
    MuscleGroup.quads ||
    MuscleGroup.hamstrings ||
    MuscleGroup.glutes ||
    MuscleGroup.calves =>
      Icons.directions_run_rounded,
    MuscleGroup.fullBody => Icons.sports_martial_arts_rounded,
    MuscleGroup.cardio => Icons.favorite_rounded,
  };
}

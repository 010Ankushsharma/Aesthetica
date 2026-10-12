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

final _combatDisciplineProvider = StateProvider<String?>((ref) => null);

class CombatScreen extends ConsumerWidget {
  const CombatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(combatLessonsProvider);
    final selectedDiscipline = ref.watch(_combatDisciplineProvider);

    final disciplines = lessons.map((l) => l.discipline).toSet().toList()
      ..sort();

    final filtered = selectedDiscipline == null
        ? lessons
        : lessons.where((l) => l.discipline == selectedDiscipline).toList();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              lessonCount: lessons.length,
              onBack: () => context.pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: _DisciplineChips(
              disciplines: disciplines,
              selected: selectedDiscipline,
              onSelected: (d) =>
                  ref.read(_combatDisciplineProvider.notifier).state = d,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _LessonCard(
                      lesson: filtered[index],
                      index: index,
                    ),
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
  const _Header({required this.lessonCount, required this.onBack});

  final int lessonCount;
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
            AppColors.red.withValues(alpha: 0.25),
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
                  color: AppColors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.red.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.sports_martial_arts_rounded,
                  color: AppColors.red,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Combat Training',
                      style: context.textTheme.displaySmall,
                    ).animate().fadeIn().slideX(begin: -0.05, end: 0),
                    Text(
                      '$lessonCount lessons • Striking & conditioning',
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

class _DisciplineChips extends StatelessWidget {
  const _DisciplineChips({
    required this.disciplines,
    required this.selected,
    required this.onSelected,
  });

  final List<String> disciplines;
  final String? selected;
  final ValueChanged<String?> onSelected;

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
            color: AppColors.red,
            onTap: () {
              context.hapticSelection();
              onSelected(null);
            },
          ),
          ...disciplines.map(
            (d) => _Chip(
              label: d,
              isSelected: selected == d,
              color: AppColors.red,
              onTap: () {
                context.hapticSelection();
                onSelected(d);
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
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
            color: isSelected ? color.withValues(alpha: 0.2) : AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.5)
                  : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: isSelected ? color : AppColors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, required this.index});

  final CombatLesson lesson;
  final int index;

  @override
  Widget build(BuildContext context) {
    final difficultyColor = _difficultyColor(lesson.difficulty);

    return GlassCard(
      onTap: () {
        context.hapticLight();
        context.push('/combat/${lesson.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  lesson.discipline,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  _difficultyLabel(lesson.difficulty),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: difficultyColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(lesson.name, style: context.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            lesson.description,
            style: context.textTheme.bodySmall?.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _MetaItem(
                icon: Icons.timer_outlined,
                label: '${lesson.durationMinutes} min',
              ),
              const SizedBox(width: AppSpacing.lg),
              _MetaItem(
                icon: Icons.local_fire_department_outlined,
                label: '${lesson.caloriesBurned} kcal',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Combinations',
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: lesson.combinations
                .map(
                  (c) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardElevated,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      c,
                      style: context.textTheme.labelMedium,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (100 + index * 60).ms)
        .slideY(begin: 0.06, end: 0);
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(label, style: context.textTheme.labelMedium),
      ],
    );
  }
}

Color _difficultyColor(Difficulty d) {
  return switch (d) {
    Difficulty.beginner => AppColors.green,
    Difficulty.intermediate => AppColors.accent,
    Difficulty.advanced => AppColors.red,
  };
}

String _difficultyLabel(Difficulty d) {
  return switch (d) {
    Difficulty.beginner => 'Beginner',
    Difficulty.intermediate => 'Intermediate',
    Difficulty.advanced => 'Advanced',
  };
}

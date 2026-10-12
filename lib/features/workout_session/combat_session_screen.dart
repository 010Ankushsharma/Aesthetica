import 'dart:async';
import 'dart:math';

import 'package:aesthetica/core/constants/app_colors.dart';
import 'package:aesthetica/core/constants/app_spacing.dart';
import 'package:aesthetica/core/utils/extensions.dart';
import 'package:aesthetica/core/widgets/gradient_button.dart';
import 'package:aesthetica/core/widgets/progress_ring.dart';
import 'package:aesthetica/data/models/models.dart';
import 'package:aesthetica/data/repositories/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CombatSessionScreen extends ConsumerStatefulWidget {
  const CombatSessionScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<CombatSessionScreen> createState() =>
      _CombatSessionScreenState();
}

class _CombatSessionScreenState extends ConsumerState<CombatSessionScreen> {
  CombatLesson? _lesson;
  int _round = 1;
  int _comboIndex = 0;
  int _secondsLeft = 0;
  int _elapsed = 0;
  int _techniqueScore = 85;
  bool _isActive = false;
  bool _isRest = false;
  Timer? _timer;
  final _random = Random();

  static const _roundDuration = 180;
  static const _restDuration = 60;
  static const _totalRounds = 3;

  @override
  void initState() {
    super.initState();
    _lesson = ref.read(combatRepositoryProvider).getById(widget.lessonId);
    _secondsLeft = _roundDuration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleSession() {
    context.hapticMedium();
    if (_isActive) {
      _timer?.cancel();
      setState(() => _isActive = false);
    } else {
      setState(() => _isActive = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          _elapsed++;
          if (_secondsLeft > 0) {
            _secondsLeft--;
            if (_elapsed % 15 == 0) {
              _techniqueScore =
                  (_techniqueScore + _random.nextInt(5) - 1).clamp(70, 99);
            }
          } else {
            _onRoundEnd();
          }
        });
      });
    }
  }

  void _onRoundEnd() {
    if (_round >= _totalRounds) {
      _finish();
      return;
    }
    setState(() {
      _isRest = true;
      _secondsLeft = _restDuration;
      _round++;
      _comboIndex = 0;
    });
  }

  void _nextCombo() {
    context.hapticLight();
    if (_lesson == null) return;
    setState(() {
      _comboIndex = (_comboIndex + 1) % _lesson!.combinations.length;
      _techniqueScore =
          (_techniqueScore + _random.nextInt(4)).clamp(70, 100);
    });
  }

  Future<void> _finish() async {
    _timer?.cancel();
    final lesson = _lesson;
    if (lesson == null) return;

    await ref.read(userNotifierProvider.notifier).completeWorkout(
          durationSeconds: _elapsed,
          caloriesBurned: lesson.caloriesBurned,
          title: lesson.name,
          exerciseIds: [lesson.id],
        );

    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_mma_rounded, color: AppColors.red, size: 56),
            const SizedBox(height: AppSpacing.md),
            Text('Session Complete', style: context.textTheme.headlineMedium),
            Text(
              'Technique Score: $_techniqueScore%',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.green,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(
              label: 'Done',
              width: double.infinity,
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    final combo = lesson.combinations[_comboIndex];
    final progress = _isRest
        ? 1 - (_secondsLeft / _restDuration)
        : 1 - (_secondsLeft / _roundDuration);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Expanded(
                    child: Text(
                      lesson.name,
                      style: context.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    'R$_round/$_totalRounds',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      _isRest ? 'REST' : 'FIGHT',
                      style: context.textTheme.displayMedium?.copyWith(
                        color: _isRest ? AppColors.blue : AppColors.red,
                        letterSpacing: 4,
                      ),
                    ).animate(target: _isActive ? 1 : 0).shimmer(
                          duration: 1200.ms,
                          color: AppColors.accent.withValues(alpha: 0.3),
                        ),
                    const SizedBox(height: AppSpacing.lg),
                    ProgressRing(
                      progress: progress,
                      size: 220,
                      lineWidth: 14,
                      color: _isRest ? AppColors.blue : AppColors.red,
                      center: Text(
                        _formatTime(_secondsLeft),
                        style: context.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (!_isRest) ...[
                      Text(
                        'COMBINATION',
                        style: context.textTheme.labelSmall?.copyWith(
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        combo,
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineLarge?.copyWith(
                          color: AppColors.accent,
                        ),
                      ).animate(key: ValueKey(combo)).fadeIn().scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                          ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Tap when combo complete',
                        style: context.textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton.icon(
                        onPressed: _nextCombo,
                        icon: const Icon(Icons.swap_horiz_rounded),
                        label: const Text('Next Combo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(color: AppColors.accent),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MetricChip(
                          icon: Icons.local_fire_department,
                          label: '${lesson.caloriesBurned} kcal',
                        ),
                        _MetricChip(
                          icon: Icons.grade_rounded,
                          label: '$_techniqueScore%',
                        ),
                        _MetricChip(
                          icon: Icons.timer_rounded,
                          label: _formatTime(_elapsed),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: GradientButton(
                label: _isActive ? 'Pause' : 'Start Round',
                icon: _isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                width: double.infinity,
                onPressed: _toggleSession,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(label, style: context.textTheme.labelMedium),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:aesthetica/core/constants/app_colors.dart';
import 'package:aesthetica/core/constants/app_spacing.dart';
import 'package:aesthetica/core/services/notification_service.dart';
import 'package:aesthetica/core/utils/extensions.dart';
import 'package:aesthetica/core/widgets/gradient_button.dart';
import 'package:aesthetica/core/widgets/progress_ring.dart';
import 'package:aesthetica/data/models/models.dart';
import 'package:aesthetica/data/models/workout_session.dart';
import 'package:aesthetica/data/repositories/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({
    super.key,
    required this.exerciseIds,
    this.title = 'Workout',
  });

  final List<String> exerciseIds;
  final String title;

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  late List<Exercise> _exercises;
  int _exerciseIndex = 0;
  int _currentSet = 1;
  int _repsDone = 0;
  SessionPhase _phase = SessionPhase.exercise;
  int _restSecondsLeft = 0;
  int _elapsedSeconds = 0;
  Timer? _timer;
  Timer? _restTimer;

  @override
  void initState() {
    super.initState();
    _exercises =
        ref.read(exerciseRepositoryProvider).getByIds(widget.exerciseIds);
    if (_exercises.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
      return;
    }
    _startElapsedTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  void _startElapsedTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _phase != SessionPhase.rest) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  Exercise get _current => _exercises[_exerciseIndex];
  int get _totalSets => _current.sets;
  double get _overallProgress =>
      (_exerciseIndex + (_currentSet - 1) / _totalSets) / _exercises.length;

  int _parseTargetReps() {
    final reps = _current.reps.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(reps) ?? 10;
  }

  void _completeSet() {
    context.hapticMedium();
    if (_currentSet >= _totalSets) {
      if (_exerciseIndex >= _exercises.length - 1) {
        _finishWorkout();
        return;
      }
      _startRest(_current.restSeconds, nextExercise: true);
    } else {
      _startRest(_current.restSeconds);
      setState(() => _currentSet++);
      _repsDone = 0;
    }
  }

  void _startRest(int seconds, {bool nextExercise = false}) {
    _restTimer?.cancel();
    setState(() {
      _phase = SessionPhase.rest;
      _restSecondsLeft = seconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_restSecondsLeft <= 1) {
        t.cancel();
        setState(() {
          _phase = SessionPhase.exercise;
          if (nextExercise) {
            _exerciseIndex++;
            _currentSet = 1;
          }
          _repsDone = 0;
        });
        context.hapticLight();
      } else {
        setState(() => _restSecondsLeft--);
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _phase = SessionPhase.exercise;
      if (_currentSet > _totalSets) {
        _exerciseIndex++;
        _currentSet = 1;
      }
      _repsDone = 0;
    });
  }

  Future<void> _finishWorkout() async {
    _timer?.cancel();
    _restTimer?.cancel();
    setState(() => _phase = SessionPhase.complete);

    final calories = _exercises
        .map((e) => (e.caloriesPerMinute * e.durationMinutes).round())
        .fold<int>(0, (a, b) => a + b);

    final xp = await ref.read(userNotifierProvider.notifier).completeWorkout(
          durationSeconds: _elapsedSeconds,
          caloriesBurned: calories,
          title: widget.title,
          exerciseIds: widget.exerciseIds,
        );

    await NotificationService.instance.showInstant(
      id: 1,
      title: 'Workout Complete!',
      body: 'You earned $xp XP. Great work!',
    );

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CompletionSheet(
        title: widget.title,
        duration: _elapsedSeconds,
        calories: calories,
        xp: xp,
        onDone: () {
          Navigator.pop(ctx);
          context.go('/home');
        },
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_exercises.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (_phase == SessionPhase.rest) {
      return _RestView(
        secondsLeft: _restSecondsLeft,
        totalRest: _current.restSeconds,
        nextLabel: _currentSet > _totalSets
            ? _exercises[_exerciseIndex + 1].name
            : '${_current.name} — Set ${_currentSet + 1}',
        onSkip: _skipRest,
      );
    }

    final targetReps = _parseTargetReps();
    final repProgress = (_repsDone / targetReps).clamp(0.0, 1.0);

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
                    onPressed: () => _confirmExit(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.title,
                          style: context.textTheme.titleMedium,
                        ),
                        Text(
                          _formatTime(_elapsedSeconds),
                          style: context.textTheme.headlineSmall?.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_exerciseIndex + 1}/${_exercises.length}',
                    style: context.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: _overallProgress,
              backgroundColor: AppColors.border,
              color: AppColors.accent,
              minHeight: 4,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      _current.name,
                      textAlign: TextAlign.center,
                      style: context.textTheme.displaySmall,
                    ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Set $_currentSet of $_totalSets • ${_current.reps} reps',
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ProgressRing(
                      progress: repProgress,
                      size: 200,
                      lineWidth: 12,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_repsDone',
                            style: context.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '/ $targetReps reps',
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RepButton(
                          icon: Icons.remove_rounded,
                          onTap: () {
                            if (_repsDone > 0) {
                              context.hapticSelection();
                              setState(() => _repsDone--);
                            }
                          },
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        _RepButton(
                          icon: Icons.add_rounded,
                          isPrimary: true,
                          onTap: () {
                            context.hapticLight();
                            setState(() => _repsDone++);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (_current.instructions.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Form Cue',
                              style: context.textTheme.titleSmall?.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _current.instructions.first,
                              style: context.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: GradientButton(
                label: _repsDone >= targetReps ? 'Complete Set' : 'Complete Set Early',
                icon: Icons.check_rounded,
                width: double.infinity,
                onPressed: _completeSet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Workout?'),
        content: const Text('Your progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (leave == true && context.mounted) context.pop();
  }
}

class _RepButton extends StatelessWidget {
  const _RepButton({
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.accent : AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPrimary
                  ? AppColors.accent
                  : AppColors.border,
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 32,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class _RestView extends StatelessWidget {
  const _RestView({
    required this.secondsLeft,
    required this.totalRest,
    required this.nextLabel,
    required this.onSkip,
  });

  final int secondsLeft;
  final int totalRest;
  final String nextLabel;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (secondsLeft / totalRest);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              Text('REST', style: context.textTheme.displayMedium),
              const SizedBox(height: AppSpacing.lg),
              ProgressRing(
                progress: progress,
                size: 220,
                lineWidth: 14,
                color: AppColors.blue,
                center: Text(
                  '$secondsLeft',
                  style: context.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Up next: $nextLabel',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.grey,
                ),
              ),
              const Spacer(),
              GradientButton(
                label: 'Skip Rest',
                icon: Icons.skip_next_rounded,
                width: double.infinity,
                onPressed: onSkip,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletionSheet extends StatelessWidget {
  const _CompletionSheet({
    required this.title,
    required this.duration,
    required this.calories,
    required this.xp,
    required this.onDone,
  });

  final String title;
  final int duration;
  final int calories;
  final int xp;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final minutes = duration ~/ 60;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1A08), AppColors.card],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.accent, size: 64),
          const SizedBox(height: AppSpacing.md),
          Text('Workout Complete!', style: context.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: context.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat('$minutes min', 'Duration'),
              _Stat('$calories', 'Calories'),
              _Stat('+$xp', 'XP'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: 'Done',
            width: double.infinity,
            onPressed: onDone,
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0).fadeIn();
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: context.textTheme.headlineSmall?.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
        )),
        Text(label, style: context.textTheme.labelSmall),
      ],
    );
  }
}

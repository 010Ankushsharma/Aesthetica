class WorkoutSessionConfig {
  const WorkoutSessionConfig({
    required this.exerciseIds,
    this.title = 'Workout',
  });

  final List<String> exerciseIds;
  final String title;

  String get routeQuery =>
      'ids=${exerciseIds.join(',')}&title=${Uri.encodeComponent(title)}';
}

class WorkoutSessionResult {
  const WorkoutSessionResult({
    required this.durationSeconds,
    required this.caloriesBurned,
    required this.exercisesCompleted,
    required this.setsCompleted,
  });

  final int durationSeconds;
  final int caloriesBurned;
  final int exercisesCompleted;
  final int setsCompleted;
}

enum SessionPhase { exercise, rest, complete }

class ActiveSetState {
  const ActiveSetState({
    required this.exerciseIndex,
    required this.setNumber,
    required this.totalSets,
    required this.repsTarget,
    required this.repsCompleted,
  });

  final int exerciseIndex;
  final int setNumber;
  final int totalSets;
  final String repsTarget;
  final int repsCompleted;

  ActiveSetState copyWith({int? repsCompleted}) => ActiveSetState(
        exerciseIndex: exerciseIndex,
        setNumber: setNumber,
        totalSets: totalSets,
        repsTarget: repsTarget,
        repsCompleted: repsCompleted ?? this.repsCompleted,
      );
}

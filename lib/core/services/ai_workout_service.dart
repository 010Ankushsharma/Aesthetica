import 'package:aesthetica/data/models/models.dart';
import 'package:aesthetica/data/datasources/exercise_database.dart';

class AiWorkoutService {
  List<Exercise> generate({
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required Difficulty experience,
    required Set<WorkoutGoal> goals,
    required double timeMinutes,
    required Set<String> equipment,
  }) {
    final bmi = weightKg / ((heightCm / 100) * (heightCm / 100));
    final all = ExerciseDatabase.getAllExercises();

    var pool = all.where((e) {
      final diffOk = e.difficulty.index <= experience.index + 1;
      final equipOk = equipment.contains('Bodyweight') ||
          e.category != ExerciseCategory.beginner;
      return diffOk && equipOk;
    }).toList();

    if (goals.contains(WorkoutGoal.fatLoss)) {
      pool = _prioritize(pool, (e) =>
          e.category == ExerciseCategory.fatLoss ||
          e.targetMuscles.contains(MuscleGroup.cardio));
    }
    if (goals.contains(WorkoutGoal.muscleGain) ||
        goals.contains(WorkoutGoal.biggerChest) ||
        goals.contains(WorkoutGoal.largerArms)) {
      pool = _prioritize(pool, (e) =>
          e.category == ExerciseCategory.muscleGain ||
          e.category == ExerciseCategory.aestheticPhysique);
    }
    if (goals.contains(WorkoutGoal.visibleAbs)) {
      pool = _prioritize(
        pool,
        (e) =>
            e.targetMuscles.contains(MuscleGroup.abs) ||
            e.targetMuscles.contains(MuscleGroup.core),
      );
    }
    if (goals.contains(WorkoutGoal.combatFitness)) {
      pool = _prioritize(pool, (e) => e.category == ExerciseCategory.fatLoss);
    }

    if (bmi > 27) {
      pool = pool
          .where((e) => e.difficulty != Difficulty.advanced)
          .followedBy(pool)
          .toSet()
          .toList();
    }

    if (age > 45) {
      pool = _prioritize(pool, (e) =>
          e.category == ExerciseCategory.mobility ||
          e.category == ExerciseCategory.recovery);
    }

    final count = (timeMinutes / 10).ceil().clamp(4, 10);
    final selected = <Exercise>[];
    final usedMuscles = <MuscleGroup>{};

    pool.shuffle();
    for (final exercise in pool) {
      if (selected.length >= count) break;
      final overlap = exercise.targetMuscles
          .where((m) => usedMuscles.contains(m) && m != MuscleGroup.fullBody);
      if (overlap.length > 1 && selected.length > 2) continue;
      selected.add(exercise);
      usedMuscles.addAll(exercise.targetMuscles);
    }

    while (selected.length < count && selected.length < pool.length) {
      final next = pool.firstWhere(
        (e) => !selected.contains(e),
        orElse: () => pool.first,
      );
      if (!selected.contains(next)) selected.add(next);
      if (selected.length >= pool.length) break;
    }

    return selected;
  }

  List<Exercise> _prioritize(
    List<Exercise> pool,
    bool Function(Exercise) predicate,
  ) {
    final preferred = pool.where(predicate).toList();
    final rest = pool.where((e) => !predicate(e)).toList();
    return [...preferred, ...rest];
  }
}

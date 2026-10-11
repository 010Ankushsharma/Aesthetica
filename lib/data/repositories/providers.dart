import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/app_prefs.dart';
import '../datasources/combat_database.dart';
import '../datasources/exercise_database.dart';
import '../models/models.dart';
import 'user_notifier.dart';

class ExerciseRepository {
  List<Exercise> getAll() => ExerciseDatabase.getAllExercises();
  Exercise? getById(String id) => ExerciseDatabase.getById(id);
  List<Exercise> getByCategory(ExerciseCategory category) =>
      ExerciseDatabase.getByCategory(category);
  List<Exercise> getByDifficulty(Difficulty difficulty) =>
      ExerciseDatabase.getByDifficulty(difficulty);
  List<Exercise> search(String query) => ExerciseDatabase.search(query);
  List<Exercise> getFeatured() => getAll().take(12).toList();
  List<Exercise> getByIds(List<String> ids) =>
      ids.map(getById).whereType<Exercise>().toList();
}

class CombatRepository {
  List<CombatLesson> getAll() => CombatDatabase.getAllLessons();
  List<CombatLesson> getByDiscipline(String discipline) =>
      CombatDatabase.getByDiscipline(discipline);
  CombatLesson? getById(String id) => CombatDatabase.getById(id);
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main');
});

final appPrefsProvider = Provider<AppPrefs>((ref) {
  return AppPrefs(ref.watch(sharedPreferencesProvider));
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(appPrefsProvider));
});

final userNotifierProvider =
    StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (ref) => ExerciseRepository(),
);

final combatRepositoryProvider = Provider<CombatRepository>(
  (ref) => CombatRepository(),
);

final exercisesProvider = Provider<List<Exercise>>(
  (ref) => ref.watch(exerciseRepositoryProvider).getAll(),
);

final featuredExercisesProvider = Provider<List<Exercise>>(
  (ref) => ref.watch(exerciseRepositoryProvider).getFeatured(),
);

final userProfileProvider = Provider<UserProfile>(
  (ref) => ref.watch(userNotifierProvider).profile,
);

final dailyStatsProvider = Provider<DailyStats>(
  (ref) => ref.watch(userNotifierProvider).stats,
);

final combatLessonsProvider = Provider<List<CombatLesson>>(
  (ref) => ref.watch(combatRepositoryProvider).getAll(),
);

final achievementsProvider = Provider<List<Achievement>>(
  (ref) => ref.watch(userNotifierProvider).achievements,
);

final weeklyCaloriesProvider = Provider<List<double>>(
  (ref) => ref.watch(userNotifierProvider).weeklyCalories,
);

final monthlyWeightProvider = Provider<List<double>>(
  (ref) => ref.watch(userNotifierProvider).monthlyWeight,
);

final measurementsProvider = Provider<Map<String, double>>(
  (ref) => ref.watch(userNotifierProvider).measurements,
);

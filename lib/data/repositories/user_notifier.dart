import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/app_prefs.dart';
import '../../core/services/storage_service.dart';
import '../models/models.dart';

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isGuest = false,
    this.email,
  });

  final bool isAuthenticated;
  final bool isGuest;
  final String? email;

  bool get canAccessApp => isAuthenticated || isGuest;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._prefs) : super(const AuthState()) {
    _load();
  }

  final AppPrefs _prefs;

  void _load() {
    final mode = _prefs.authMode;
    if (mode == 'guest') {
      state = const AuthState(isGuest: true);
    } else if (mode == 'email') {
      state = AuthState(
        isAuthenticated: true,
        email: _prefs.userEmail,
      );
    }
  }

  Future<String?> signUp(String email, String password, String name) async {
    final box = StorageService.instance.auth;
    if (box.containsKey(email)) return 'Account already exists';

    await box.put(email, {'password': password, 'name': name});
    await _prefs.setAuthMode('email');
    await _prefs.setUserEmail(email);
    state = AuthState(isAuthenticated: true, email: email);
    return null;
  }

  Future<String?> signIn(String email, String password) async {
    final creds = StorageService.instance.auth.get(email);
    if (creds == null) return 'Account not found';
    if (creds['password'] != password) return 'Incorrect password';

    await _prefs.setAuthMode('email');
    await _prefs.setUserEmail(email);
    state = AuthState(isAuthenticated: true, email: email);
    return null;
  }

  Future<void> continueAsGuest() async {
    await _prefs.setAuthMode('guest');
    state = const AuthState(isGuest: true);
  }

  Future<void> signOut() async {
    await _prefs.setAuthMode(null);
    await _prefs.setUserEmail(null);
    state = const AuthState();
  }
}

class UserState {
  const UserState({
    required this.profile,
    required this.stats,
    required this.weeklyCalories,
    required this.monthlyWeight,
    required this.achievements,
    required this.measurements,
    this.mood = 4,
    this.energy = 3.5,
  });

  final UserProfile profile;
  final DailyStats stats;
  final List<double> weeklyCalories;
  final List<double> monthlyWeight;
  final List<Achievement> achievements;
  final Map<String, double> measurements;
  final double mood;
  final double energy;

  UserState copyWith({
    UserProfile? profile,
    DailyStats? stats,
    List<double>? weeklyCalories,
    List<double>? monthlyWeight,
    List<Achievement>? achievements,
    Map<String, double>? measurements,
    double? mood,
    double? energy,
  }) =>
      UserState(
        profile: profile ?? this.profile,
        stats: stats ?? this.stats,
        weeklyCalories: weeklyCalories ?? this.weeklyCalories,
        monthlyWeight: monthlyWeight ?? this.monthlyWeight,
        achievements: achievements ?? this.achievements,
        measurements: measurements ?? this.measurements,
        mood: mood ?? this.mood,
        energy: energy ?? this.energy,
      );
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(_defaultState()) {
    _load();
  }

  static UserState _defaultState() => UserState(
        profile: const UserProfile(
          id: 'user_1',
          name: 'Alex Rivera',
          email: 'alex@aesthetica.app',
          age: 26,
          gender: 'Male',
          heightCm: 178,
          weightKg: 78,
          bodyFatPercent: 14.2,
          experience: Difficulty.intermediate,
          goals: [WorkoutGoal.athleticBuild, WorkoutGoal.visibleAbs],
          streak: 12,
          level: 8,
          xp: 2450,
          coins: 380,
        ),
        stats: const DailyStats(
          caloriesBurned: 1847,
          caloriesGoal: 2500,
          caloriesRemaining: 653,
          steps: 7243,
          stepsGoal: 10000,
          waterMl: 2100,
          waterGoalMl: 3000,
          sleepHours: 7.5,
          sleepScore: 82,
          recoveryScore: 76,
          heartRate: 68,
          workoutMinutes: 42,
          moveRing: 0.72,
          exerciseRing: 0.85,
          standRing: 0.9,
        ),
        weeklyCalories: [1650, 2100, 1847, 1920, 2200, 1780, 1847],
        monthlyWeight: [79.5, 79.2, 78.9, 78.7, 78.5, 78.3, 78.0, 78.0],
        achievements: _defaultAchievements(),
        measurements: {
          'Chest': 102,
          'Waist': 81,
          'Shoulders': 118,
          'Arms': 38,
          'Thighs': 58,
          'Neck': 39,
        },
      );

  static List<Achievement> _defaultAchievements() => const [
        Achievement(
          id: 'a1',
          title: 'First Workout',
          description: 'Complete your first workout',
          icon: Icons.fitness_center,
          xpReward: 100,
          isUnlocked: true,
        ),
        Achievement(
          id: 'a2',
          title: '7-Day Streak',
          description: 'Work out 7 days in a row',
          icon: Icons.local_fire_department,
          xpReward: 250,
          isUnlocked: true,
        ),
        Achievement(
          id: 'a3',
          title: 'Iron Will',
          description: 'Complete 50 workouts',
          icon: Icons.military_tech,
          xpReward: 500,
          isUnlocked: false,
        ),
        Achievement(
          id: 'a4',
          title: 'Perfect Month',
          description: 'Work out every day for a month',
          icon: Icons.emoji_events,
          xpReward: 1000,
          isUnlocked: false,
        ),
      ];

  void _load() {
    final box = StorageService.instance.user;
    final profileMap = box.get('profile');
    final statsMap = box.get('stats');
    final measurements = box.get('measurements');
    final weekly = box.get('weekly_calories');
    final monthly = box.get('monthly_weight');
    final mood = box.get('mood');
    final energy = box.get('energy');

    state = state.copyWith(
      profile: profileMap != null
          ? _profileFromMap(Map<String, dynamic>.from(profileMap as Map))
          : state.profile,
      stats: statsMap != null
          ? _statsFromMap(Map<String, dynamic>.from(statsMap as Map))
          : state.stats,
      measurements: measurements != null
          ? Map<String, double>.from(
              (measurements as Map).map(
                (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
              ),
            )
          : state.measurements,
      weeklyCalories: weekly != null
          ? List<double>.from(
              (weekly as List).map((e) => (e as num).toDouble()),
            )
          : state.weeklyCalories,
      monthlyWeight: monthly != null
          ? List<double>.from(
              (monthly as List).map((e) => (e as num).toDouble()),
            )
          : state.monthlyWeight,
      mood: mood != null ? (mood as num).toDouble() : state.mood,
      energy: energy != null ? (energy as num).toDouble() : state.energy,
    );
  }

  Future<void> _persist() async {
    final box = StorageService.instance.user;
    await box.put('profile', _profileToMap(state.profile));
    await box.put('stats', _statsToMap(state.stats));
    await box.put('measurements', state.measurements);
    await box.put('weekly_calories', state.weeklyCalories);
    await box.put('monthly_weight', state.monthlyWeight);
    await box.put('mood', state.mood);
    await box.put('energy', state.energy);
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = state.copyWith(profile: profile);
    await _persist();
  }

  Future<void> saveTrackerLog({
    required double waterMl,
    required double recovery,
    required double mood,
    required double energy,
    Map<String, double>? measurements,
  }) async {
    final stats = state.stats;
    state = state.copyWith(
      stats: DailyStats(
        caloriesBurned: stats.caloriesBurned,
        caloriesGoal: stats.caloriesGoal,
        caloriesRemaining: stats.caloriesRemaining,
        steps: stats.steps,
        stepsGoal: stats.stepsGoal,
        waterMl: waterMl.round(),
        waterGoalMl: stats.waterGoalMl,
        sleepHours: stats.sleepHours,
        sleepScore: stats.sleepScore,
        recoveryScore: recovery.round(),
        heartRate: stats.heartRate,
        workoutMinutes: stats.workoutMinutes,
        moveRing: stats.moveRing,
        exerciseRing: stats.exerciseRing,
        standRing: stats.standRing,
      ),
      measurements: measurements ?? state.measurements,
      mood: mood,
      energy: energy,
    );
    await _persist();

    final today = DateTime.now().toIso8601String().split('T').first;
    await StorageService.instance.tracker.put(today, {
      'water_ml': waterMl,
      'recovery': recovery,
      'mood': mood,
      'energy': energy,
      'measurements': measurements ?? state.measurements,
      'saved_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> completeWorkout({
    required int durationSeconds,
    required int caloriesBurned,
    required String title,
    required List<String> exerciseIds,
  }) async {
    final xpEarned = (caloriesBurned / 5).round().clamp(25, 200);
    final coinsEarned = (durationSeconds / 60).round().clamp(5, 50);
    final newXp = state.profile.xp + xpEarned;
    final newLevel = 1 + (newXp / 500).floor();
    final newStreak = state.profile.streak + 1;

    final stats = state.stats;
    final newCalories = stats.caloriesBurned + caloriesBurned;
    final weekly = List<double>.from(state.weeklyCalories);
    if (weekly.isNotEmpty) {
      weekly[weekly.length - 1] = newCalories.toDouble();
    }

    state = state.copyWith(
      profile: state.profile.copyWith(
        xp: newXp,
        level: newLevel,
        coins: state.profile.coins + coinsEarned,
        streak: newStreak,
      ),
      stats: DailyStats(
        caloriesBurned: newCalories,
        caloriesGoal: stats.caloriesGoal,
        caloriesRemaining: (stats.caloriesGoal - newCalories).clamp(0, 9999),
        steps: stats.steps,
        stepsGoal: stats.stepsGoal,
        waterMl: stats.waterMl,
        waterGoalMl: stats.waterGoalMl,
        sleepHours: stats.sleepHours,
        sleepScore: stats.sleepScore,
        recoveryScore: stats.recoveryScore,
        heartRate: stats.heartRate,
        workoutMinutes: stats.workoutMinutes + (durationSeconds ~/ 60),
        moveRing: (stats.moveRing + 0.1).clamp(0.0, 1.0),
        exerciseRing: (stats.exerciseRing + 0.15).clamp(0.0, 1.0),
        standRing: stats.standRing,
      ),
      weeklyCalories: weekly,
    );

    await _persist();
    await StorageService.instance.workouts.add({
      'title': title,
      'exercise_ids': exerciseIds,
      'duration_seconds': durationSeconds,
      'calories': caloriesBurned,
      'completed_at': DateTime.now().toIso8601String(),
      'xp_earned': xpEarned,
    });

    return xpEarned;
  }

  Map<String, dynamic> _profileToMap(UserProfile p) => {
        'id': p.id,
        'name': p.name,
        'email': p.email,
        'age': p.age,
        'gender': p.gender,
        'heightCm': p.heightCm,
        'weightKg': p.weightKg,
        'bodyFatPercent': p.bodyFatPercent,
        'experience': p.experience.name,
        'goals': p.goals.map((g) => g.name).toList(),
        'streak': p.streak,
        'level': p.level,
        'xp': p.xp,
        'coins': p.coins,
      };

  UserProfile _profileFromMap(Map<String, dynamic> m) => UserProfile(
        id: m['id'] as String,
        name: m['name'] as String,
        email: m['email'] as String,
        age: m['age'] as int,
        gender: m['gender'] as String,
        heightCm: (m['heightCm'] as num).toDouble(),
        weightKg: (m['weightKg'] as num).toDouble(),
        bodyFatPercent: (m['bodyFatPercent'] as num).toDouble(),
        experience: Difficulty.values.byName(m['experience'] as String),
        goals: (m['goals'] as List)
            .map((g) => WorkoutGoal.values.byName(g as String))
            .toList(),
        streak: m['streak'] as int,
        level: m['level'] as int,
        xp: m['xp'] as int,
        coins: m['coins'] as int,
      );

  Map<String, dynamic> _statsToMap(DailyStats s) => {
        'caloriesBurned': s.caloriesBurned,
        'caloriesGoal': s.caloriesGoal,
        'caloriesRemaining': s.caloriesRemaining,
        'steps': s.steps,
        'stepsGoal': s.stepsGoal,
        'waterMl': s.waterMl,
        'waterGoalMl': s.waterGoalMl,
        'sleepHours': s.sleepHours,
        'sleepScore': s.sleepScore,
        'recoveryScore': s.recoveryScore,
        'heartRate': s.heartRate,
        'workoutMinutes': s.workoutMinutes,
        'moveRing': s.moveRing,
        'exerciseRing': s.exerciseRing,
        'standRing': s.standRing,
      };

  DailyStats _statsFromMap(Map<String, dynamic> m) => DailyStats(
        caloriesBurned: m['caloriesBurned'] as int,
        caloriesGoal: m['caloriesGoal'] as int,
        caloriesRemaining: m['caloriesRemaining'] as int,
        steps: m['steps'] as int,
        stepsGoal: m['stepsGoal'] as int,
        waterMl: m['waterMl'] as int,
        waterGoalMl: m['waterGoalMl'] as int,
        sleepHours: (m['sleepHours'] as num).toDouble(),
        sleepScore: m['sleepScore'] as int,
        recoveryScore: m['recoveryScore'] as int,
        heartRate: m['heartRate'] as int,
        workoutMinutes: m['workoutMinutes'] as int,
        moveRing: (m['moveRing'] as num).toDouble(),
        exerciseRing: (m['exerciseRing'] as num).toDouble(),
        standRing: (m['standRing'] as num).toDouble(),
      );
}

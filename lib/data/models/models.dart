import 'package:flutter/material.dart';

enum Difficulty { beginner, intermediate, advanced }

enum ExerciseCategory {
  beginner,
  intermediate,
  advanced,
  fatLoss,
  muscleGain,
  aestheticPhysique,
  mobility,
  stretching,
  flexibility,
  warmup,
  cooldown,
  recovery,
}

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  abs,
  obliques,
  quads,
  hamstrings,
  glutes,
  calves,
  core,
  fullBody,
  cardio,
}

enum WorkoutGoal {
  vTaper,
  wideShoulders,
  biggerChest,
  largerArms,
  visibleAbs,
  leanLegs,
  athleticBuild,
  calisthenics,
  streetWorkout,
  summerBody,
  beginnerTransformation,
  transformation90,
  transformation180,
  transformation365,
  combatFitness,
  fatLoss,
  muscleGain,
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.targetMuscles,
    required this.caloriesPerMinute,
    required this.durationMinutes,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.instructions,
    required this.commonMistakes,
    required this.tips,
    this.imageUrl,
    this.videoUrl,
  });

  final String id;
  final String name;
  final ExerciseCategory category;
  final Difficulty difficulty;
  final List<MuscleGroup> targetMuscles;
  final double caloriesPerMinute;
  final int durationMinutes;
  final int sets;
  final String reps;
  final int restSeconds;
  final List<String> instructions;
  final List<String> commonMistakes;
  final List<String> tips;
  final String? imageUrl;
  final String? videoUrl;

  String get difficultyLabel => switch (difficulty) {
        Difficulty.beginner => 'Beginner',
        Difficulty.intermediate => 'Intermediate',
        Difficulty.advanced => 'Advanced',
      };

  String get categoryLabel => switch (category) {
        ExerciseCategory.beginner => 'Beginner',
        ExerciseCategory.intermediate => 'Intermediate',
        ExerciseCategory.advanced => 'Advanced',
        ExerciseCategory.fatLoss => 'Fat Loss',
        ExerciseCategory.muscleGain => 'Muscle Gain',
        ExerciseCategory.aestheticPhysique => 'Aesthetic Physique',
        ExerciseCategory.mobility => 'Mobility',
        ExerciseCategory.stretching => 'Stretching',
        ExerciseCategory.flexibility => 'Flexibility',
        ExerciseCategory.warmup => 'Warmup',
        ExerciseCategory.cooldown => 'Cooldown',
        ExerciseCategory.recovery => 'Recovery',
      };
}

class Workout {
  const Workout({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.difficulty,
    required this.goal,
    this.isCompleted = false,
  });

  final String id;
  final String name;
  final String description;
  final List<Exercise> exercises;
  final int durationMinutes;
  final int caloriesBurned;
  final Difficulty difficulty;
  final WorkoutGoal goal;
  final bool isCompleted;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.age = 25,
    this.gender = 'Male',
    this.heightCm = 175,
    this.weightKg = 75,
    this.bodyFatPercent = 15,
    this.experience = Difficulty.intermediate,
    this.goals = const [],
    this.streak = 0,
    this.level = 1,
    this.xp = 0,
    this.coins = 0,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final double bodyFatPercent;
  final Difficulty experience;
  final List<WorkoutGoal> goals;
  final int streak;
  final int level;
  final int xp;
  final int coins;

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  UserProfile copyWith({
    String? name,
    int? streak,
    int? level,
    int? xp,
    int? coins,
    double? weightKg,
    double? bodyFatPercent,
  }) =>
      UserProfile(
        id: id,
        name: name ?? this.name,
        email: email,
        avatarUrl: avatarUrl,
        age: age,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg ?? this.weightKg,
        bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
        experience: experience,
        goals: goals,
        streak: streak ?? this.streak,
        level: level ?? this.level,
        xp: xp ?? this.xp,
        coins: coins ?? this.coins,
      );
}

class DailyStats {
  const DailyStats({
    this.caloriesBurned = 0,
    this.caloriesGoal = 2500,
    this.caloriesRemaining = 2500,
    this.steps = 0,
    this.stepsGoal = 10000,
    this.waterMl = 0,
    this.waterGoalMl = 3000,
    this.sleepHours = 0,
    this.sleepScore = 0,
    this.recoveryScore = 0,
    this.heartRate = 0,
    this.workoutMinutes = 0,
    this.moveRing = 0,
    this.exerciseRing = 0,
    this.standRing = 0,
  });

  final int caloriesBurned;
  final int caloriesGoal;
  final int caloriesRemaining;
  final int steps;
  final int stepsGoal;
  final int waterMl;
  final int waterGoalMl;
  final double sleepHours;
  final int sleepScore;
  final int recoveryScore;
  final int heartRate;
  final int workoutMinutes;
  final double moveRing;
  final double exerciseRing;
  final double standRing;

  double get caloriesProgress => caloriesBurned / caloriesGoal;
  double get stepsProgress => steps / stepsGoal;
  double get waterProgress => waterMl / waterGoalMl;
}

class CombatLesson {
  const CombatLesson({
    required this.id,
    required this.name,
    required this.discipline,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.difficulty,
    required this.description,
    required this.combinations,
  });

  final String id;
  final String name;
  final String discipline;
  final int durationMinutes;
  final int caloriesBurned;
  final Difficulty difficulty;
  final String description;
  final List<String> combinations;
}

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
}

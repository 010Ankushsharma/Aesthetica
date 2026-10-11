import '../models/models.dart';

abstract final class CombatDatabase {
  static final List<CombatLesson> _lessons = [
    const CombatLesson(
      id: 'c1',
      name: 'Shadow Boxing Fundamentals',
      discipline: 'Boxing',
      durationMinutes: 20,
      caloriesBurned: 180,
      difficulty: Difficulty.beginner,
      description: 'Master basic punches, footwork, and defensive movements.',
      combinations: ['Jab-Cross', 'Jab-Cross-Hook', 'Double Jab-Cross'],
    ),
    const CombatLesson(
      id: 'c2',
      name: 'Kickboxing HIIT',
      discipline: 'Kickboxing',
      durationMinutes: 30,
      caloriesBurned: 320,
      difficulty: Difficulty.intermediate,
      description: 'High-intensity kickboxing combinations with cardio bursts.',
      combinations: ['Jab-Cross-Roundhouse', 'Teep-Cross-Hook', 'Switch Kick Combo'],
    ),
    const CombatLesson(
      id: 'c3',
      name: 'Karate Basics',
      discipline: 'Karate',
      durationMinutes: 25,
      caloriesBurned: 200,
      difficulty: Difficulty.beginner,
      description: 'Learn fundamental stances, blocks, and strikes.',
      combinations: ['Front Punch-Block', 'Front Kick-Punch', 'Kata Flow'],
    ),
    const CombatLesson(
      id: 'c4',
      name: 'Taekwondo Kicks',
      discipline: 'Taekwondo',
      durationMinutes: 25,
      caloriesBurned: 240,
      difficulty: Difficulty.intermediate,
      description: 'Dynamic kicking techniques and flexibility drills.',
      combinations: ['Front Kick-Roundhouse', 'Side Kick-Back Kick', 'Spinning Hook'],
    ),
    const CombatLesson(
      id: 'c5',
      name: 'Muay Thai Clinch',
      discipline: 'Muay Thai',
      durationMinutes: 30,
      caloriesBurned: 350,
      difficulty: Difficulty.advanced,
      description: 'Elbows, knees, and clinch work for full-body conditioning.',
      combinations: ['Elbow-Knee', 'Clinch Knee-Elbow', 'Sweep Combo'],
    ),
    const CombatLesson(
      id: 'c6',
      name: 'MMA Conditioning',
      discipline: 'MMA',
      durationMinutes: 35,
      caloriesBurned: 400,
      difficulty: Difficulty.advanced,
      description: 'Mixed martial arts conditioning with ground and standup.',
      combinations: ['Sprawl-Punch', 'Takedown-Guard', 'Ground & Pound'],
    ),
    const CombatLesson(
      id: 'c7',
      name: 'Footwork Drills',
      discipline: 'Boxing',
      durationMinutes: 15,
      caloriesBurned: 120,
      difficulty: Difficulty.beginner,
      description: 'Agility ladder patterns and ring movement.',
      combinations: ['Pivot Drill', 'L-Step', 'Angle Off'],
    ),
    const CombatLesson(
      id: 'c8',
      name: 'Defensive Mastery',
      discipline: 'Boxing',
      durationMinutes: 20,
      caloriesBurned: 150,
      difficulty: Difficulty.intermediate,
      description: 'Slip, roll, parry, and counter techniques.',
      combinations: ['Slip-Counter', 'Roll-Hook', 'Parry-Cross'],
    ),
    const CombatLesson(
      id: 'c9',
      name: 'Reaction Training',
      discipline: 'Combat',
      durationMinutes: 15,
      caloriesBurned: 130,
      difficulty: Difficulty.intermediate,
      description: 'Improve reflexes with visual and audio cues.',
      combinations: ['Random Combo', 'Defense React', 'Counter Drill'],
    ),
    const CombatLesson(
      id: 'c10',
      name: 'Heavy Bag Simulation',
      discipline: 'Boxing',
      durationMinutes: 25,
      caloriesBurned: 280,
      difficulty: Difficulty.intermediate,
      description: 'Power punching combinations on the heavy bag.',
      combinations: ['1-2-3-2', 'Body Shot Combo', 'Power Cross-Hook'],
    ),
    const CombatLesson(
      id: 'c11',
      name: 'No Equipment Combat',
      discipline: 'Combat',
      durationMinutes: 20,
      caloriesBurned: 200,
      difficulty: Difficulty.beginner,
      description: 'Full combat workout with zero equipment needed.',
      combinations: ['Shadow Combo', 'Air Kicks', 'Defense Flow'],
    ),
    const CombatLesson(
      id: 'c12',
      name: 'Speed & Reflex Drills',
      discipline: 'Combat',
      durationMinutes: 18,
      caloriesBurned: 160,
      difficulty: Difficulty.advanced,
      description: 'Explosive speed drills for faster reactions.',
      combinations: ['Speed Jab', 'Double Tap', 'Flash Combo'],
    ),
  ];

  static List<CombatLesson> getAllLessons() => List.unmodifiable(_lessons);

  static List<CombatLesson> getByDiscipline(String discipline) =>
      _lessons.where((l) => l.discipline == discipline).toList();

  static CombatLesson? getById(String id) {
    try {
      return _lessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<String> get disciplines =>
      _lessons.map((l) => l.discipline).toSet().toList();
}

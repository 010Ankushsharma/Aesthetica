import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  StorageService._();
  static final instance = StorageService._();

  static const userBox = 'user_data';
  static const trackerBox = 'tracker_logs';
  static const workoutBox = 'workout_history';
  static const authBox = 'auth_credentials';

  Future<void> ensureOpen() async {
    if (!Hive.isBoxOpen(userBox)) await Hive.openBox(userBox);
    if (!Hive.isBoxOpen(trackerBox)) await Hive.openBox(trackerBox);
    if (!Hive.isBoxOpen(workoutBox)) await Hive.openBox(workoutBox);
    if (!Hive.isBoxOpen(authBox)) await Hive.openBox(authBox);
  }

  Box get user => Hive.box(userBox);
  Box get tracker => Hive.box(trackerBox);
  Box get workouts => Hive.box(workoutBox);
  Box get auth => Hive.box(authBox);
}

import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  AppPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingKey = 'onboarding_complete';
  static const _authModeKey = 'auth_mode';
  static const _userEmailKey = 'user_email';
  static const _reminderHourKey = 'reminder_hour';
  static const _reminderMinuteKey = 'reminder_minute';
  static const _remindersEnabledKey = 'reminders_enabled';

  bool get onboardingComplete => _prefs.getBool(_onboardingKey) ?? false;
  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_onboardingKey, value);

  String? get authMode => _prefs.getString(_authModeKey);
  Future<void> setAuthMode(String? mode) {
    if (mode == null) return _prefs.remove(_authModeKey);
    return _prefs.setString(_authModeKey, mode);
  }

  String? get userEmail => _prefs.getString(_userEmailKey);
  Future<void> setUserEmail(String? email) {
    if (email == null) return _prefs.remove(_userEmailKey);
    return _prefs.setString(_userEmailKey, email);
  }

  bool get remindersEnabled => _prefs.getBool(_remindersEnabledKey) ?? false;
  Future<void> setRemindersEnabled(bool value) =>
      _prefs.setBool(_remindersEnabledKey, value);

  int get reminderHour => _prefs.getInt(_reminderHourKey) ?? 7;
  int get reminderMinute => _prefs.getInt(_reminderMinuteKey) ?? 0;

  Future<void> setReminderTime(int hour, int minute) async {
    await _prefs.setInt(_reminderHourKey, hour);
    await _prefs.setInt(_reminderMinuteKey, minute);
  }
}

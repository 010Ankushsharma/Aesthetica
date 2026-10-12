import 'package:aesthetica/core/constants/app_colors.dart';
import 'package:aesthetica/core/constants/app_spacing.dart';
import 'package:aesthetica/core/services/notification_service.dart';
import 'package:aesthetica/core/utils/extensions.dart';
import 'package:aesthetica/core/widgets/gradient_button.dart';
import 'package:aesthetica/data/repositories/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  late bool _enabled;
  late TimeOfDay _reminderTime;
  bool _waterReminder = true;
  bool _stretchReminder = true;
  bool _recoveryReminder = false;
  bool _achievementNotif = true;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(appPrefsProvider);
    _enabled = prefs.remindersEnabled;
    _reminderTime = TimeOfDay(
      hour: prefs.reminderHour,
      minute: prefs.reminderMinute,
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  Future<void> _save() async {
    final prefs = ref.read(appPrefsProvider);
    await prefs.setRemindersEnabled(_enabled);
    await prefs.setReminderTime(_reminderTime.hour, _reminderTime.minute);

    if (_enabled) {
      await NotificationService.instance.requestPermissions();
      await NotificationService.instance.scheduleDailyReminder(
        id: 100,
        title: 'Time to Train',
        body: 'Your workout is waiting. Keep the streak alive!',
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
      if (_waterReminder) {
        await NotificationService.instance.scheduleDailyReminder(
          id: 101,
          title: 'Stay Hydrated',
          body: 'Drink a glass of water.',
          hour: 12,
          minute: 0,
        );
      }
    } else {
      await NotificationService.instance.cancelAll();
    }

    if (mounted) {
      context.hapticMedium();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings saved')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SwitchListTile(
            title: const Text('Workout Reminders'),
            subtitle: const Text('Daily push notifications'),
            value: _enabled,
            activeThumbColor: AppColors.accent,
            onChanged: (v) => setState(() => _enabled = v),
          ),
          if (_enabled) ...[
            ListTile(
              title: const Text('Daily Reminder Time'),
              subtitle: Text(_reminderTime.format(context)),
              trailing: const Icon(Icons.schedule_rounded),
              onTap: _pickTime,
            ),
            SwitchListTile(
              title: const Text('Water Reminder'),
              value: _waterReminder,
              activeThumbColor: AppColors.accent,
              onChanged: (v) => setState(() => _waterReminder = v),
            ),
            SwitchListTile(
              title: const Text('Stretch Reminder'),
              value: _stretchReminder,
              activeThumbColor: AppColors.accent,
              onChanged: (v) => setState(() => _stretchReminder = v),
            ),
            SwitchListTile(
              title: const Text('Recovery Reminder'),
              value: _recoveryReminder,
              activeThumbColor: AppColors.accent,
              onChanged: (v) => setState(() => _recoveryReminder = v),
            ),
            SwitchListTile(
              title: const Text('Achievement Alerts'),
              value: _achievementNotif,
              activeThumbColor: AppColors.accent,
              onChanged: (v) => setState(() => _achievementNotif = v),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: 'Save Settings',
            width: double.infinity,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

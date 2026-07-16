// lib/screens/settings/settings_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/export_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'package:ufit/theme/theme_ext.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  bool _waterRemindersOn = false;
  bool _habitRemindersOn = false;
  bool _sleepReminderOn = false;
  int _sleepHour = 22;
  int _sleepMinute = 30;
  int _waterStartHour = 8;
  int _waterStartMinute = 0;
  int _waterEndHour = 22;
  int _waterEndMinute = 0;
  int _waterIntervalHours = 2;

  String _formatTimeOfDay(int hour, int minute) {
    final time = TimeOfDay(hour: hour, minute: minute);
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hourStr = time.hourOfPeriod == 0 ? '12' : time.hourOfPeriod.toString();
    final minStr = time.minute.toString().padLeft(2, '0');
    return '$hourStr:$minStr $period';
  }

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadNotifPrefs();
    _reloadUser();
  }

  Future<void> _reloadUser() async {
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      // Trigger a rebuild so emailVerified status is fresh
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appVersion = '${info.version} (${info.buildNumber})');
  }

  Future<void> _loadNotifPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _waterRemindersOn = prefs.getBool('water_reminders_on') ?? false;
        _habitRemindersOn = prefs.getBool('habit_reminders_on') ?? false;
        _sleepReminderOn = prefs.getBool('sleep_reminders_on') ?? false;
        _sleepHour = prefs.getInt('sleep_reminder_hour') ?? 22;
        _sleepMinute = prefs.getInt('sleep_reminder_minute') ?? 30;
        _waterStartHour = prefs.getInt('water_start_hour') ?? 8;
        _waterStartMinute = prefs.getInt('water_start_minute') ?? 0;
        _waterEndHour = prefs.getInt('water_end_hour') ?? 22;
        _waterEndMinute = prefs.getInt('water_end_minute') ?? 0;
        _waterIntervalHours = prefs.getInt('water_interval_hours') ?? 2;
      });
    }
  }

  Future<void> _saveNotifPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final user = ref.watch(userProvider);
    final isPremium = ref.watch(premiumProvider);
    final firebaseUser = ref.watch(currentFirebaseUserProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // ── Account Section ────────────────────────────────
          _SectionLabel('Account'),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                UserAvatar(
                  radius: 28,
                  photoUrl: firebaseUser?.photoURL,
                  initial: user?.name.isNotEmpty == true ? (user?.name[0].toUpperCase() ?? 'U') : 'U',
                  isPremium: isPremium,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? firebaseUser?.displayName ?? 'User', style: Theme.of(context).textTheme.titleLarge),
                      Text(firebaseUser?.email ?? '', style: Theme.of(context).textTheme.bodySmall),
                      if (firebaseUser != null && !firebaseUser.emailVerified && firebaseUser.providerData.any((p) => p.providerId == 'password'))
                        GestureDetector(
                          onTap: () => _resendVerification(),
                          child: const Text('⚠️ Email not verified — tap to resend', style: TextStyle(color: AppColors.accentOrange, fontSize: 11)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          _SettingTile(icon: Icons.edit_outlined, label: 'Edit Profile', onTap: () => context.push('/edit-profile')),
          _SettingTile(icon: Icons.lock_outline_rounded, label: 'Change Password', onTap: () => _changePasswordSheet()),
          _SettingTile(
            icon: Icons.verified_user_outlined,
            label: 'Account Type',
            trailing: isPremium 
                ? (user?.premiumPlan == 'ufit_pro_monthly' 
                    ? '✨ Pro (Monthly)' 
                    : user?.premiumPlan == 'ufit_pro_yearly'
                        ? '✨ Pro (Yearly)'
                        : user?.premiumPlan == 'ufit_pro_lifetime'
                            ? '✨ Pro (Lifetime)'
                            : '✨ Pro')
                : 'Free',
            trailingColor: isPremium ? AppColors.primary : null,
            onTap: () => context.push('/premium'),
          ),

          const SizedBox(height: 20),

          // ── Goals Section ─────────────────────────────────
          _SectionLabel('Daily Goals'),
          _GoalTile(
            icon: '💧',
            label: 'Water Goal',
            value: '${user?.dailyWaterGoalMl ?? 2500} ml',
            color: AppColors.waterColor,
            onTap: () => _editGoalSheet(context, 'Water Goal (ml)', user?.dailyWaterGoalMl ?? 2500, 500, 5000, (v) {
              if (user != null) { user.dailyWaterGoalMl = v; ref.read(userProvider.notifier).saveUser(user); }
            }),
          ),
          _GoalTile(
            icon: '🌙',
            label: 'Sleep Goal',
            value: '${user?.sleepGoalHours ?? 8} hours',
            color: AppColors.sleepColor,
            onTap: () => _editGoalSheet(context, 'Sleep Goal (hours)', user?.sleepGoalHours ?? 8, 4, 12, (v) {
              if (user != null) { user.sleepGoalHours = v; ref.read(userProvider.notifier).saveUser(user); }
            }),
          ),
          _GoalTile(
            icon: '🚶',
            label: 'Steps Goal',
            value: '${user?.dailyStepsGoal ?? 10000} steps',
            color: AppColors.workoutColor,
            onTap: () => _editGoalSheet(context, 'Daily Steps', user?.dailyStepsGoal ?? 10000, 1000, 30000, (v) {
              if (user != null) { user.dailyStepsGoal = v; ref.read(userProvider.notifier).saveUser(user); }
            }),
          ),
          _GoalTile(
            icon: '🎯',
            label: 'Target Weight',
            value: '${user?.targetWeightKg.toStringAsFixed(1) ?? '70.0'} kg',
            color: AppColors.weightColor,
            onTap: () => _editTargetWeightSheet(context, user?.targetWeightKg ?? 70.0),
          ),

          const SizedBox(height: 20),

          // ── Notifications ─────────────────────────────────
          _SectionLabel('Notifications'),
          _SwitchTile(
            icon: Icons.local_drink_outlined,
            label: 'Water Reminders',
            subtitle: 'Tap to configure (${_waterIntervalHours}h interval, ${_formatTimeOfDay(_waterStartHour, _waterStartMinute)} - ${_formatTimeOfDay(_waterEndHour, _waterEndMinute)})',
            value: _waterRemindersOn,
            onTap: _showWaterReminderConfigDialog,
            onChanged: (v) async {
              setState(() => _waterRemindersOn = v);
              await _saveNotifPref('water_reminders_on', v);
              if (v) {
                await NotificationService.requestPermissions();
                await NotificationService.scheduleWaterReminder();
              } else {
                await NotificationService.cancelWaterReminders();
              }
            },
          ),
          _SwitchTile(
            icon: Icons.task_alt_outlined,
            label: 'Habit Reminders',
            subtitle: 'Based on each habit schedule',
            value: _habitRemindersOn,
            onChanged: (v) async {
              setState(() => _habitRemindersOn = v);
              await _saveNotifPref('habit_reminders_on', v);
              if (v) {
                await NotificationService.requestPermissions();
                final habits = ref.read(habitsProvider);
                for (final habit in habits) {
                  if (habit.reminderEnabled && habit.reminderTime != null) {
                    await NotificationService.scheduleHabitReminder(
                      id: habit.id.hashCode,
                      habitName: habit.name,
                      time: habit.reminderTime!,
                      weekDays: habit.weekDays,
                    );
                  }
                }
              } else {
                final habits = ref.read(habitsProvider);
                for (final habit in habits) {
                  await NotificationService.cancelHabitReminders(habit.id.hashCode);
                }
              }
            },
          ),
          _SwitchTile(
            icon: Icons.bedtime_outlined,
            label: 'Sleep Reminder',
            subtitle: 'Tap to change bedtime (${_formatTimeOfDay(_sleepHour, _sleepMinute)})',
            value: _sleepReminderOn,
            onTap: () async {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: _sleepHour, minute: _sleepMinute),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: context.card,
                        onSurface: context.text,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (selectedTime != null) {
                setState(() {
                  _sleepHour = selectedTime.hour;
                  _sleepMinute = selectedTime.minute;
                  _sleepReminderOn = true;
                });
                await _saveNotifPref('sleep_reminders_on', true);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('sleep_reminder_hour', selectedTime.hour);
                await prefs.setInt('sleep_reminder_minute', selectedTime.minute);

                await NotificationService.requestPermissions();
                await NotificationService.scheduleSleepReminder(selectedTime.hour, selectedTime.minute);
              }
            },
            onChanged: (v) async {
              setState(() => _sleepReminderOn = v);
              await _saveNotifPref('sleep_reminders_on', v);
              if (v) {
                await NotificationService.requestPermissions();
                await NotificationService.scheduleSleepReminder(_sleepHour, _sleepMinute);
              } else {
                await NotificationService.cancelSleepReminder();
              }
            },
          ),


          const SizedBox(height: 20),

          // ── Appearance ────────────────────────────────────
          _SectionLabel('Appearance'),
          _SwitchTile(
            icon: Icons.dark_mode_outlined,
            label: 'Dark Mode',
            value: isDark,
            onChanged: (v) => ref.read(themeProvider.notifier).setDark(v),
          ),

          const SizedBox(height: 20),

          // ── Data & Privacy ────────────────────────────────
          _SectionLabel('Data & Privacy'),
          _SettingTile(
            icon: Icons.file_download_outlined,
            label: 'Export My Data',
            isPro: !isPremium,
            onTap: () {
              if (!isPremium) {
                context.push('/premium');
                return;
              }
              _exportData();
            },
          ),
          _SettingTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () => context.push('/legal-privacy'),
          ),

          const SizedBox(height: 20),



          // ── Support ───────────────────────────────────────
          _SectionLabel('Support'),
          _SettingTile(icon: Icons.info_outline_rounded, label: 'About uFit', onTap: () => context.push('/about')),
          _SettingTile(icon: Icons.help_outline_rounded, label: 'Help Center', onTap: () => context.push('/help-center')),
          _SettingTile(icon: Icons.mail_outline_rounded, label: 'Contact Support', onTap: () => _launchUrl('mailto:support.ufit@gmail.com?subject=uFit Support')),
          _SettingTile(icon: Icons.star_outline_rounded, label: 'Rate uFit ⭐', onTap: () => _showInfoDialog('Rate uFit', 'Thank you for using uFit! ❤️\n\nWe will add the Play Store link here once the app is published. Stay tuned!')),
          _SettingTile(icon: Icons.share_rounded, label: 'Share App', onTap: () => _shareApp()),
          _SettingTile(icon: Icons.description_outlined, label: 'Terms of Service', onTap: () => context.push('/legal-terms')),

          const SizedBox(height: 20),

          // ── Sign Out ──────────────────────────────────────
          _SectionLabel('Account Actions'),
          _SettingTile(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            isDestructive: true,
            onTap: () => _confirmSignOut(),
          ),
          _SettingTile(
            icon: Icons.delete_forever_rounded,
            label: 'Delete Account',
            isDestructive: true,
            onTap: () => _confirmDeleteAccount(),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _editGoalSheet(BuildContext context, String title, int current, int min, int max, Function(int) onSave) {
    int value = current;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: context.surface,
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$value', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.primary)),
              Slider(
                value: value.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                activeColor: AppColors.primary,
                inactiveColor: context.border,
                onChanged: (v) => setState(() => value = v.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(onPressed: () { 
              onSave(value); 
              Navigator.pop(ctx); 
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goal updated successfully! 🎉')));
            }, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  void _editTargetWeightSheet(BuildContext context, double current) {
    double value = current;
    final user = ref.read(userProvider);
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: context.surface,
          title: const Text('Target Weight'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${value.toStringAsFixed(1)} kg', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.weightColor)),
              Slider(
                value: value,
                min: 30,
                max: 200,
                divisions: 340,
                activeColor: AppColors.weightColor,
                inactiveColor: context.border,
                onChanged: (v) => setState(() => value = double.parse(v.toStringAsFixed(1))),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (user != null) { user.targetWeightKg = value; ref.read(userProvider.notifier).saveUser(user); }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Target weight updated! ⚖️')));
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _changePasswordSheet() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change Password', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            TextField(controller: oldPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Current Password')),
            const SizedBox(height: 12),
            TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New Password')),
            const SizedBox(height: 12),
            TextField(controller: confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm New Password')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (newPassCtrl.text != confirmCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                    return;
                  }
                  try {
                    await AuthService.updatePassword(newPassCtrl.text);
                    if (mounted) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated ✓'), backgroundColor: AppColors.success));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
                  }
                },
                child: const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resendVerification() async {
    try {
      await AuthService.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent!'), backgroundColor: AppColors.success));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _exportData() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Export Data', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Choose the format for your data export.', style: TextStyle(color: context.textSecondary)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined, color: AppColors.primary),
                title: const Text('Export as CSV'),
                subtitle: const Text('Best for spreadsheets (Excel, Google Sheets)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _runExport(ExportService.exportAllData);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined, color: Colors.redAccent),
                title: const Text('Export as PDF Document'),
                subtitle: const Text('Best for printing and sharing reports'),
                onTap: () {
                  Navigator.pop(ctx);
                  _runExport(ExportService.exportAllDataAsPDF);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runExport(Future<void> Function() exportAction) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating your data export...')),
      );
      await exportAction();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showWaterReminderConfigDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int startH = _waterStartHour;
        int startM = _waterStartMinute;
        int endH = _waterEndHour;
        int endM = _waterEndMinute;
        int interval = _waterIntervalHours;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: context.card,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.local_drink_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Text('Water Reminders', style: TextStyle(color: context.text, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configure your daily hydration prompts. Reminders will only repeat during this window.',
                    style: TextStyle(color: context.textSecondary, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  // Start & End Time row
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: startH, minute: startM),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: AppColors.primary,
                                      onPrimary: Colors.white,
                                      surface: context.card,
                                      onSurface: context.text,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (t != null) {
                              setDialogState(() {
                                startH = t.hour;
                                startM = t.minute;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            decoration: BoxDecoration(
                              color: context.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.border.withOpacity(0.5)),
                            ),
                            child: Column(
                              children: [
                                Text('Start Time', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTimeOfDay(startH, startM),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: endH, minute: endM),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: AppColors.primary,
                                      onPrimary: Colors.white,
                                      surface: context.card,
                                      onSurface: context.text,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (t != null) {
                              setDialogState(() {
                                endH = t.hour;
                                endM = t.minute;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            decoration: BoxDecoration(
                              color: context.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.border.withOpacity(0.5)),
                            ),
                            child: Column(
                              children: [
                                Text('End Time', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTimeOfDay(endH, endM),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Frequency (Interval) selector
                  Text('Reminder Frequency', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textSecondary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.border.withOpacity(0.5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: interval,
                        isExpanded: true,
                        dropdownColor: context.card,
                        style: TextStyle(color: context.text, fontSize: 14),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Every 1 hour')),
                          DropdownMenuItem(value: 2, child: Text('Every 2 hours')),
                          DropdownMenuItem(value: 3, child: Text('Every 3 hours')),
                          DropdownMenuItem(value: 4, child: Text('Every 4 hours')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => interval = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _waterStartHour = startH;
                      _waterStartMinute = startM;
                      _waterEndHour = endH;
                      _waterEndMinute = endM;
                      _waterIntervalHours = interval;
                      _waterRemindersOn = true;
                    });

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('water_start_hour', startH);
                    await prefs.setInt('water_start_minute', startM);
                    await prefs.setInt('water_end_hour', endH);
                    await prefs.setInt('water_end_minute', endM);
                    await prefs.setInt('water_interval_hours', interval);
                    await prefs.setBool('water_reminders_on', true);

                    await NotificationService.requestPermissions();
                    await NotificationService.scheduleWaterReminder();

                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.surface,
        title: Text(title),
        content: SingleChildScrollView(child: Text(content, style: const TextStyle(height: 1.6))),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _shareApp() {
    SharePlus.instance.share(
      ShareParams(
        text: '🏋️ Check out uFit — Your All-in-One Daily Health & Fitness Companion! Track habits, water, workouts, sleep, weight & more. Download it now! 💪\n\nhttps://play.google.com/store/apps/details?id=com.fittrack.ufit',
      ),
    );
  }


  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.surface,
        title: const Text('Sign Out?'),
        content: const Text('You can sign back in anytime.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.signOut();
              ref.read(userProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.surface,
        title: const Text('Delete Account?'),
        content: const Text('This PERMANENTLY deletes your account and all data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await AuthService.deleteAccount();
                ref.read(userProvider.notifier).logout();
              } catch (e) {
                if (mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 4),
    child: Text(label.toUpperCase(), style: TextStyle(color: context.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
  );
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final Color? trailingColor;
  final bool isDestructive;
  final bool isPro;

  const _SettingTile({required this.icon, required this.label, required this.onTap, this.trailing, this.trailingColor, this.isDestructive = false, this.isPro = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isDestructive ? AppColors.error : context.textSecondary),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(color: isDestructive ? AppColors.error : context.text, fontSize: 14, fontWeight: FontWeight.w500))),
            if (isPro) Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
              child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
            ),
            if (trailing != null) Text(trailing!, style: TextStyle(color: trailingColor ?? context.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: isDestructive ? AppColors.error.withOpacity(0.5) : context.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _GoalTile({required this.icon, required this.label, required this.value, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: context.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final Function(bool) onChanged;
  final VoidCallback? onTap;

  const _SwitchTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 11, color: context.textSecondary)),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

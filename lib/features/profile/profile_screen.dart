import 'package:aesthetica/core/constants/app_colors.dart';
import 'package:aesthetica/core/constants/app_spacing.dart';
import 'package:aesthetica/core/utils/extensions.dart';
import 'package:aesthetica/core/widgets/glass_card.dart';
import 'package:aesthetica/core/widgets/gradient_button.dart';
import 'package:aesthetica/core/widgets/stat_card.dart';
import 'package:aesthetica/data/models/models.dart';
import 'package:aesthetica/data/repositories/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const int _xpPerLevel = 500;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final achievements = ref.watch(achievementsProvider);
    final stats = ref.watch(dailyStatsProvider);

    final xpInLevel = profile.xp % _xpPerLevel;
    final xpProgress = xpInLevel / _xpPerLevel;
    final xpToNext = _xpPerLevel - xpInLevel;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHero(
              profile: profile,
              xpProgress: xpProgress,
              xpToNext: xpToNext,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _GamificationRow(profile: profile, stats: stats),
                const SizedBox(height: AppSpacing.lg),
                _AchievementsSection(achievements: achievements),
                const SizedBox(height: AppSpacing.lg),
                _SettingsSection(),
                const SizedBox(height: AppSpacing.lg),
                GradientButton(
                  label: 'Edit Profile',
                  icon: Icons.edit_rounded,
                  onPressed: () {
                    context.hapticLight();
                    context.push('/profile/edit');
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.profile,
    required this.xpProgress,
    required this.xpToNext,
  });

  final UserProfile profile;
  final double xpProgress;
  final int xpToNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.paddingOf(context).top + AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        children: [
          Hero(
            tag: 'avatar',
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  profile.name[0],
                  style: context.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: AppSpacing.md),
          Text(
            profile.name,
            style: context.textTheme.headlineMedium,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: context.textTheme.bodySmall?.copyWith(color: AppColors.grey),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            'LVL ${profile.level}',
                            style: context.textTheme.labelLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${profile.xp.formatted} XP',
                          style: context.textTheme.titleSmall?.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$xpToNext to next',
                      style: context.textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: xpProgress),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      backgroundColor: AppColors.border,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

class _GamificationRow extends StatelessWidget {
  const _GamificationRow({required this.profile, required this.stats});

  final UserProfile profile;
  final dynamic stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Streak',
            value: '${profile.streak}',
            unit: 'days',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.accent,
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.05, end: 0),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: StatCard(
            label: 'Coins',
            value: profile.coins.formatted,
            icon: Icons.monetization_on_rounded,
            color: AppColors.accentSecondary,
          ).animate().fadeIn(delay: 350.ms),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: StatCard(
            label: 'Workouts',
            value: '${stats.workoutMinutes}',
            unit: 'min',
            icon: Icons.fitness_center_rounded,
            color: AppColors.green,
          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.05, end: 0),
        ),
      ],
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({required this.achievements});

  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a.isUnlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Achievements', style: context.textTheme.headlineSmall),
            Text(
              '$unlocked / ${achievements.length}',
              style: context.textTheme.labelMedium?.copyWith(
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.15,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _AchievementCard(achievement: achievement, index: index);
          },
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement, required this.index});

  final Achievement achievement;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: (isUnlocked ? AppColors.accent : AppColors.greyDark)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              achievement.icon,
              color: isUnlocked ? AppColors.accent : AppColors.greyDark,
              size: 24,
            ),
          ),
          const Spacer(),
          Text(
            achievement.title,
            style: context.textTheme.titleSmall?.copyWith(
              color: isUnlocked ? AppColors.white : AppColors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            achievement.description,
            style: context.textTheme.labelSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.stars_rounded,
                size: 14,
                color: isUnlocked ? AppColors.accentSecondary : AppColors.greyDark,
              ),
              const SizedBox(width: 4),
              Text(
                '+${achievement.xpReward} XP',
                style: context.textTheme.labelSmall?.copyWith(
                  color: isUnlocked ? AppColors.accentSecondary : AppColors.greyDark,
                ),
              ),
              const Spacer(),
              if (!isUnlocked)
                const Icon(Icons.lock_rounded, size: 14, color: AppColors.greyDark),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (450 + index * 80).ms)
        .scale(begin: const Offset(0.95, 0.95));
  }
}

class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Settings', style: context.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        _SettingsGroup(
          title: 'Notifications',
          items: [
            _SettingItem(
              icon: Icons.notifications_active_rounded,
              label: 'Push Notifications',
              subtitle: 'Workout reminders & streaks',
              color: AppColors.accent,
              onTap: () => context.push('/settings/notifications'),
            ),
            _SettingItem(
              icon: Icons.schedule_rounded,
              label: 'Daily Reminder',
              subtitle: '7:00 AM',
              color: AppColors.blue,
              onTap: () => context.push('/settings/notifications'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _SettingsGroup(
          title: 'Account',
          items: [
            _SettingItem(
              icon: Icons.person_outline_rounded,
              label: 'Personal Info',
              subtitle: 'Name, age, gender',
              color: AppColors.green,
              onTap: () => context.push('/profile/edit'),
            ),
            _SettingItem(
              icon: Icons.security_rounded,
              label: 'Privacy & Security',
              subtitle: 'Password, 2FA',
              color: AppColors.red,
              onTap: () => context.push('/login'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _SettingsGroup(
          title: 'Preferences',
          items: const [
            _SettingItem(
              icon: Icons.palette_rounded,
              label: 'Appearance',
              subtitle: 'Dark mode',
              color: AppColors.accentSecondary,
            ),
            _SettingItem(
              icon: Icons.straighten_rounded,
              label: 'Units',
              subtitle: 'Metric (kg, cm)',
              color: AppColors.blue,
            ),
            _SettingItem(
              icon: Icons.language_rounded,
              label: 'Language',
              subtitle: 'English',
              color: AppColors.grey,
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.items});

  final String title;
  final List<_SettingItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(
            title.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.grey,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        context.hapticLight();
                        item.onTap?.call();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                              child: Icon(item.icon, color: item.color, size: 20),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.label,
                                    style: context.textTheme.titleSmall,
                                  ),
                                  Text(
                                    item.subtitle,
                                    style: context.textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.greyDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isLast) const Divider(color: AppColors.border, height: 1),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingItem {
  const _SettingItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
}

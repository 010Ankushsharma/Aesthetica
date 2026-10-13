import 'package:aesthetica/core/constants/app_colors.dart';
import 'package:aesthetica/core/constants/app_spacing.dart';
import 'package:aesthetica/core/utils/extensions.dart';
import 'package:aesthetica/core/widgets/glass_card.dart';
import 'package:aesthetica/data/models/models.dart';
import 'package:aesthetica/data/repositories/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SocialScreen extends ConsumerWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final achievements = ref.watch(achievementsProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              profile: profile,
              onBack: () => context.pop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _LeaderboardSection(currentUser: profile.name)
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.lg),
                _ChallengesSection()
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.lg),
                _FriendsFeed()
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: AppSpacing.lg),
                _AchievementsPreview(achievements: achievements)
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.05, end: 0),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile, required this.onBack});

  final dynamic profile;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.paddingOf(context).top + AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.blue.withValues(alpha: 0.2),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.card.withValues(alpha: 0.6),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: AppColors.blue,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community',
                      style: context.textTheme.displaySmall,
                    ).animate().fadeIn().slideX(begin: -0.05, end: 0),
                    Text(
                      'Level ${profile.level} • ${profile.xp} XP',
                      style: context.textTheme.bodySmall,
                    ).animate().fadeIn(delay: 80.ms),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection({required this.currentUser});

  final String currentUser;

  static const _leaders = [
    ('Marcus Chen', 4820, 1),
    ('Sofia Reyes', 4100, 2),
    ('Alex Rivera', 2450, 3),
    ('Jordan Lee', 2180, 4),
    ('Taylor Kim', 1920, 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.leaderboard_rounded, color: AppColors.accent),
            const SizedBox(width: AppSpacing.sm),
            Text('Leaderboard', style: context.textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          child: Column(
            children: _leaders.asMap().entries.map((e) {
              final (name, xp, rank) = e.value;
              final isCurrentUser = name == currentUser;
              final medalColor = switch (rank) {
                1 => AppColors.accentSecondary,
                2 => AppColors.greyLight,
                3 => const Color(0xFFCD7F32),
                _ => null,
              };

              return Padding(
                padding: EdgeInsets.only(
                  bottom: e.key < _leaders.length - 1 ? AppSpacing.md : 0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: medalColor?.withValues(alpha: 0.2) ??
                            AppColors.cardElevated,
                        shape: BoxShape.circle,
                        border: isCurrentUser
                            ? Border.all(color: AppColors.blue, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: context.textTheme.labelLarge?.copyWith(
                            color: medalColor ?? AppColors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        name,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: isCurrentUser ? AppColors.blue : null,
                          fontWeight:
                              isCurrentUser ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    Text(
                      '$xp XP',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ChallengesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final challenges = [
      (
        '30-Day Shred',
        'Complete 20 workouts this month',
        0.65,
        AppColors.red,
        Icons.local_fire_department_rounded,
      ),
      (
        'Step Master',
        'Walk 70,000 steps this week',
        0.42,
        AppColors.green,
        Icons.directions_walk_rounded,
      ),
      (
        'Hydration Hero',
        'Hit water goal 7 days straight',
        0.85,
        AppColors.blue,
        Icons.water_drop_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events_outlined, color: AppColors.accent),
            const SizedBox(width: AppSpacing.sm),
            Text('Active Challenges', style: context.textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...challenges.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(c.$5, color: c.$4, size: 22),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(c.$1, style: context.textTheme.titleSmall),
                      ),
                      Text(
                        '${(c.$3 * 100).toInt()}%',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: c.$4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    c.$2,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: c.$3,
                      backgroundColor: AppColors.border,
                      color: c.$4,
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FriendsFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final feed = [
      (
        'Marcus Chen',
        'Completed Aesthetic Push Day',
        '45 min • 380 kcal',
        '2h ago',
        Icons.fitness_center_rounded,
        AppColors.accent,
      ),
      (
        'Sofia Reyes',
        'Hit a 14-day streak! 🔥',
        'Level 12 unlocked',
        '4h ago',
        Icons.local_fire_department_rounded,
        AppColors.red,
      ),
      (
        'Jordan Lee',
        'Finished Kickboxing HIIT',
        '30 min • 320 kcal',
        '6h ago',
        Icons.sports_martial_arts_rounded,
        AppColors.red,
      ),
      (
        'Taylor Kim',
        'New personal best: 10K steps',
        '10,247 steps today',
        '8h ago',
        Icons.directions_walk_rounded,
        AppColors.green,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.dynamic_feed_rounded, color: AppColors.blue),
            const SizedBox(width: AppSpacing.sm),
            Text('Friends Feed', style: context.textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...feed.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GlassCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          f.$6.withValues(alpha: 0.3),
                          AppColors.cardElevated,
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Center(
                      child: Text(
                        f.$1[0],
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                f.$1,
                                style: context.textTheme.titleSmall,
                              ),
                            ),
                            Text(
                              f.$4,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: AppColors.greyDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(f.$2, style: context.textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(f.$5, size: 14, color: f.$6),
                            const SizedBox(width: 4),
                            Text(
                              f.$3,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: f.$6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AchievementsPreview extends StatelessWidget {
  const _AchievementsPreview({required this.achievements});

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
            Row(
              children: [
                const Icon(Icons.military_tech_rounded, color: AppColors.accent),
                const SizedBox(width: AppSpacing.sm),
                Text('Achievements', style: context.textTheme.headlineSmall),
              ],
            ),
            Text(
              '$unlocked / ${achievements.length}',
              style: context.textTheme.labelMedium?.copyWith(
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, index) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final a = achievements[index];
              return _AchievementCard(achievement: a, index: index);
            },
          ),
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
    final unlocked = achievement.isUnlocked;

    return SizedBox(
      width: 140,
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: unlocked ? AppColors.accentGradient : null,
                color: unlocked ? null : AppColors.cardElevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                achievement.icon,
                color: unlocked ? AppColors.white : AppColors.greyDark,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              achievement.title,
              style: context.textTheme.labelMedium?.copyWith(
                color: unlocked ? AppColors.white : AppColors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (unlocked)
              Text(
                '+${achievement.xpReward} XP',
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.accent,
                ),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (450 + index * 80).ms)
        .slideX(begin: 0.1, end: 0);
  }
}

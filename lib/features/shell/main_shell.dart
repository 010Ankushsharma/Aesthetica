import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/extensions.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _getIndex(String location) {
    if (location.startsWith('/home/workouts')) return 1;
    if (location.startsWith('/home/tracker')) return 2;
    if (location.startsWith('/home/analytics')) return 3;
    if (location.startsWith('/home/profile')) return 4;
    return 0;
  }

  void _onTap(int index) {
    context.hapticSelection();
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/home/workouts');
      case 2:
        context.go('/home/tracker');
      case 3:
        context.go('/home/analytics');
      case 4:
        context.go('/home/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _getIndex(location);

    return Scaffold(
      extendBody: true,
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.hapticMedium();
          context.push('/ai-generator');
        },
        child: const Icon(Icons.auto_awesome_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.85),
              border: Border(
                top: BorderSide(
                  color: AppColors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isSelected: currentIndex == 0,
                      onTap: () => _onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.fitness_center_rounded,
                      label: 'Workouts',
                      isSelected: currentIndex == 1,
                      onTap: () => _onTap(1),
                    ),
                    const SizedBox(width: 56),
                    _NavItem(
                      icon: Icons.track_changes_rounded,
                      label: 'Tracker',
                      isSelected: currentIndex == 2,
                      onTap: () => _onTap(2),
                    ),
                    _NavItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Stats',
                      isSelected: currentIndex == 3,
                      onTap: () => _onTap(3),
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      isSelected: currentIndex == 4,
                      onTap: () => _onTap(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.accent : AppColors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? AppColors.accent : AppColors.grey,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

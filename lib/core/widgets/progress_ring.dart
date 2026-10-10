import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.center,
    this.size = 120,
    this.lineWidth = 10,
    this.color = AppColors.accent,
    this.backgroundColor,
    this.subtitle,
  });

  final double progress;
  final Widget center;
  final double size;
  final double lineWidth;
  final Color color;
  final Color? backgroundColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: size / 2,
          lineWidth: lineWidth,
          percent: progress.clamp(0.0, 1.0),
          center: center,
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: color,
          backgroundColor:
              backgroundColor ?? AppColors.border.withValues(alpha: 0.5),
          animation: true,
          animationDuration: 1200,
          curve: Curves.easeOutCubic,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ],
    );
  }
}

class ActivityRings extends StatelessWidget {
  const ActivityRings({
    super.key,
    required this.move,
    required this.exercise,
    required this.stand,
    this.size = 140,
  });

  final double move;
  final double exercise;
  final double stand;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularPercentIndicator(
            radius: size / 2,
            lineWidth: 8,
            percent: move.clamp(0.0, 1.0),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: AppColors.red,
            backgroundColor: AppColors.border.withValues(alpha: 0.3),
            animation: true,
            animationDuration: 1200,
          ),
          CircularPercentIndicator(
            radius: size / 2 - 14,
            lineWidth: 8,
            percent: exercise.clamp(0.0, 1.0),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: AppColors.green,
            backgroundColor: Colors.transparent,
            animation: true,
            animationDuration: 1400,
          ),
          CircularPercentIndicator(
            radius: size / 2 - 28,
            lineWidth: 8,
            percent: stand.clamp(0.0, 1.0),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: AppColors.blue,
            backgroundColor: Colors.transparent,
            animation: true,
            animationDuration: 1600,
          ),
        ],
      ),
    );
  }
}

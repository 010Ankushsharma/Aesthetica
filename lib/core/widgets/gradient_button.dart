import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../utils/extensions.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? AppColors.accentGradient
              : LinearGradient(
                  colors: [
                    AppColors.grey.withValues(alpha: 0.3),
                    AppColors.grey.withValues(alpha: 0.2),
                  ],
                ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading
                ? null
                : () {
                    context.hapticMedium();
                    onPressed?.call();
                  },
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: AppColors.white, size: 22),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Text(
                          label,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Studio Clean frosted glass card replicating Apple iOS HIG translucent aesthetics.
/// Uses BackdropFilter with blur sigma 12 and hairline 0.5dp micro-border.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? customFillColor;
  final Color? customBorderColor;
  final double borderWidth;
  final double blurSigma;
  final List<BoxShadow>? shadows;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 22.0,
    this.customFillColor,
    this.customBorderColor,
    this.borderWidth = 0.5,
    this.blurSigma = 12.0,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultFill = isDark ? AppColors.glassFillDark : AppColors.glassFillLight;
    final defaultBorder = isDark ? AppColors.borderDark : AppColors.borderLight;

    final defaultShadows = shadows ??
        [
          BoxShadow(
            color: isDark ? const Color(0x30000000) : AppColors.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ];

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: defaultShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding ?? const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: customFillColor ?? defaultFill,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: customBorderColor ?? defaultBorder,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/entry_model.dart';
import 'bouncy_tap.dart';

/// The 5 bouncing pebble glyphs (Great, Good, Neutral, Low, Tough)
/// with tactile micro-animations, Apple-grade spring physics, and 3D glassmorphic styling.
class PebbleMoodSelector extends StatelessWidget {
  final MoodType? selectedMood;
  final ValueChanged<MoodType> onMoodSelected;
  final bool showLabels;
  final double pebbleSize;

  const PebbleMoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    this.showLabels = true,
    this.pebbleSize = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    const moods = MoodType.values;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((mood) {
        final isSelected = selectedMood == mood;
        return _PebbleGlyph(
          mood: mood,
          isSelected: isSelected,
          size: pebbleSize,
          showLabel: showLabels,
          onTap: () {
            HapticService.selection();
            onMoodSelected(mood);
          },
        );
      }).toList(),
    );
  }
}

class _PebbleGlyph extends StatelessWidget {
  final MoodType mood;
  final bool isSelected;
  final double size;
  final bool showLabel;
  final VoidCallback onTap;

  const _PebbleGlyph({
    required this.mood,
    required this.isSelected,
    required this.size,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BouncyTap(
      onTap: onTap,
      pressedScale: 0.90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            width: size + (isSelected ? 6 : 0),
            height: size + (isSelected ? 6 : 0),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.42),
              border: Border.all(
                color: isSelected ? mood.color : Colors.transparent,
                width: isSelected ? 2.5 : 0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: mood.color.withOpacity(0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.2)
                            : AppColors.shadowColor,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.38),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    mood.color.withOpacity(isSelected ? 1.0 : 0.82),
                    mood.color.withOpacity(isSelected ? 0.88 : 0.65),
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 3D Glass Specular Crescent (Top-Left Highlight)
                  Positioned(
                    top: 4,
                    left: 6,
                    child: Container(
                      width: size * 0.36,
                      height: size * 0.20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size * 0.2),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.65),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Icon glyph or center dot
                  Icon(
                    _getMoodIcon(mood),
                    color: Colors.white,
                    size: size * 0.46,
                  ),
                ],
              ),
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? mood.color
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                letterSpacing: -0.2,
              ),
              child: Text(mood.label),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getMoodIcon(MoodType mood) {
    switch (mood) {
      case MoodType.great:
        return Icons.sentiment_very_satisfied_rounded;
      case MoodType.good:
        return Icons.sentiment_satisfied_rounded;
      case MoodType.neutral:
        return Icons.sentiment_neutral_rounded;
      case MoodType.low:
        return Icons.sentiment_dissatisfied_rounded;
      case MoodType.tough:
        return Icons.sentiment_very_dissatisfied_rounded;
    }
  }
}

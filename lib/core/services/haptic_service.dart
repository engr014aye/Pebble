import 'package:flutter/services.dart';

/// Haptic feedback service providing tactile Apple-grade micro-responses.
class HapticService {
  HapticService._();

  /// Subtle click for card taps, tags, and small switches
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Medium feedback for primary button submits and confirmation actions
  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Distinct tick when cycling through mood pebbles
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Heavy feedback for destructive actions (e.g., delete or reset)
  static Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}

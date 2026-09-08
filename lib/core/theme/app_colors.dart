import 'package:flutter/material.dart';

/// Apple Studio-Clean color palette for Pebble.
/// Designed for high clarity, frosted translucency, and serene emotional balance.
class AppColors {
  AppColors._();

  // Core Studio Light Palette
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color cardSubtle = Color(0xFFF2F4F7);
  
  // Studio Dark Palette
  static const Color darkBackground = Color(0xFF0C0E12);
  static const Color darkSurface = Color(0xFF161922);
  static const Color darkSurfaceElevated = Color(0xFF1E232F);
  static const Color darkCardSubtle = Color(0xFF1C202B);

  // Frosted Glass Tints
  static const Color glassFillLight = Color(0xC8FFFFFF); // ~78% opacity
  static const Color glassFillDark = Color(0x9E1C2230);  // ~62% opacity
  
  // Hairline Micro-borders (0.5dp, 8-12% opacity)
  static const Color borderLight = Color(0x18000000);
  static const Color borderSubtle = Color(0x0E000000);
  static const Color borderDark = Color(0x28FFFFFF);
  
  // Typography Grayscale
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // 5 Signature Mood Pebble Colors
  static const Color moodGreat = Color(0xFF10B981);    // Soft Sage / Emerald
  static const Color moodGood = Color(0xFF3B82F6);     // Warm Sky Blue
  static const Color moodNeutral = Color(0xFF8B5CF6);  // Lavender Mist
  static const Color moodLow = Color(0xFFF59E0B);      // Golden Amber
  static const Color moodTough = Color(0xFFEF4444);    // Coral Rose

  // Categorical Badges
  static const Color catMind = Color(0xFF6366F1);      // Indigo
  static const Color catCareer = Color(0xFF0284C7);    // Ocean
  static const Color catHealth = Color(0xFF10B981);    // Emerald
  static const Color catRoutine = Color(0xFFD97706);   // Warm Sand

  // Ambient Shadow
  static const Color shadowColor = Color(0x0C0F172A);
  static const Color shadowColorMedium = Color(0x180F172A);
}

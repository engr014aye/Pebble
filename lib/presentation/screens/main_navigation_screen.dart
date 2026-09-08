import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/bouncy_tap.dart';
import 'analytics/analytics_screen.dart';
import 'home/home_screen.dart';
import 'reflection/new_reflection_sheet.dart';
import 'settings/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      HapticService.selection();
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildFrostedBottomBar(isDark),
    );
  }

  Widget _buildFrostedBottomBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.45)
                : AppColors.shadowColorMedium,
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xB81A1E29)
                  : const Color(0xD8FFFFFF),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Timeline Tab
                _buildNavItem(
                  index: 0,
                  icon: CupertinoIcons.clock,
                  activeIcon: CupertinoIcons.clock_fill,
                  label: 'Timeline',
                  isDark: isDark,
                ),

                // 2. Center New Reflection Button (+)
                BouncyTap(
                  onTap: () {
                    HapticService.medium();
                    NewReflectionSheet.show(context);
                  },
                  pressedScale: 0.90,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFFFFFFFF),
                                const Color(0xFFE2E8F0),
                              ]
                            : [
                                const Color(0xFF1E293B),
                                const Color(0xFF0F172A),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.white.withOpacity(0.3)
                              : AppColors.textPrimary.withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 28,
                      color: isDark ? AppColors.textPrimary : Colors.white,
                    ),
                  ),
                ),

                // 3. Analytics Flow Tab
                _buildNavItem(
                  index: 1,
                  icon: CupertinoIcons.waveform_path,
                  activeIcon: CupertinoIcons.waveform_path_badge_plus,
                  label: 'Rhythm',
                  isDark: isDark,
                ),

                // 4. Studio Settings Tab
                _buildNavItem(
                  index: 2,
                  icon: CupertinoIcons.slider_horizontal_3,
                  activeIcon: CupertinoIcons.slider_horizontal_3,
                  label: 'Studio',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = isDark ? Colors.white : AppColors.textPrimary;
    final inactiveColor = isDark
        ? AppColors.darkTextTertiary
        : AppColors.textTertiary;

    return BouncyTap(
      onTap: () => _onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: -0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

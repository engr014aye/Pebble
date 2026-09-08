import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../logic/providers/reflection_provider.dart';
import '../../../logic/providers/theme_provider.dart';
import '../../widgets/bouncy_tap.dart';
import '../../widgets/glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    HapticService.light();
    try {
      final jsonBackup = await context.read<ReflectionProvider>().exportData();
      await SharePlus.instance.share(
        ShareParams(
          text: jsonBackup,
          subject: 'Pebble_Backup_${DateTime.now().millisecondsSinceEpoch}.json',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export data: $e')),
        );
      }
    }
  }

  void _showResetConfirmation(BuildContext context) {
    HapticService.heavy();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Reset All Reflections?'),
        content: const Text(
          'This action will permanently remove all stored reflections from local SQLite storage. This cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<ReflectionProvider>().resetAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All reflection records have been cleared.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final reflectionProvider = context.watch<ReflectionProvider>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREFERENCES & STORAGE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Studio Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '100% private, on-device SQLite database.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Privacy & Security Card
                  GlassContainer(
                    padding: const EdgeInsets.all(18),
                    borderRadius: 22,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.moodGreat.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            size: 24,
                            color: AppColors.moodGreat,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Zero Cloud • 100% Private',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Your reflections and metrics never leave your device. Stored solely in local SQLite.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.35,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Appearance Section (Cupertino Inset Grouped)
                  _buildSectionHeader('APPEARANCE', isDark),
                  const SizedBox(height: 8),
                  _buildGroupContainer(
                    isDark: isDark,
                    children: [
                      _buildTile(
                        icon: Icons.dark_mode_outlined,
                        iconColor: const Color(0xFF8B5CF6),
                        title: 'Dark Mode',
                        subtitle: themeProvider.isDarkMode
                            ? 'Studio Obsidian theme'
                            : 'Studio Porcelain light theme',
                        trailing: CupertinoSwitch(
                          value: themeProvider.isDarkMode,
                          activeTrackColor: AppColors.textPrimary,
                          onChanged: (_) => themeProvider.toggleTheme(),
                        ),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Data & Database Management
                  _buildSectionHeader('DATA MANAGEMENT', isDark),
                  const SizedBox(height: 8),
                  _buildGroupContainer(
                    isDark: isDark,
                    children: [
                      _buildTile(
                        icon: Icons.ios_share_rounded,
                        iconColor: AppColors.catCareer,
                        title: 'Export SQLite Database',
                        subtitle: 'Share full encrypted JSON telemetry backup',
                        onTap: () => _exportData(context),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildTile(
                        icon: Icons.storage_rounded,
                        iconColor: AppColors.catMind,
                        title: 'Database Statistics',
                        subtitle:
                            '${reflectionProvider.entries.length} reflections stored locally',
                        trailing: Text(
                          'Healthy',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.moodGreat,
                          ),
                        ),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildTile(
                        icon: Icons.delete_forever_rounded,
                        iconColor: AppColors.moodTough,
                        title: 'Reset All Data',
                        subtitle: 'Purge all reflection entries from SQLite',
                        titleColor: AppColors.moodTough,
                        onTap: () => _showResetConfirmation(context),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // About Section
                  _buildSectionHeader('ABOUT PEBBLE', isDark),
                  const SizedBox(height: 8),
                  _buildGroupContainer(
                    isDark: isDark,
                    children: [
                      _buildTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: AppColors.textSecondary,
                        title: 'Application ID',
                        subtitle: 'com.irisblue.pebble',
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildTile(
                        icon: Icons.verified_outlined,
                        iconColor: AppColors.textSecondary,
                        title: 'Version',
                        subtitle: '1.0.0 (Build 1)',
                        trailing: Text(
                          'Release',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                          ),
                        ),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildGroupContainer({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    required bool isDark,
  }) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: titleColor ??
                        (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
          if (trailing == null && onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
            ),
        ],
      ),
    );

    if (onTap != null) {
      return BouncyTap(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 0.5,
      thickness: 0.5,
      indent: 54,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}

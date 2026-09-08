import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/entry_model.dart';
import '../../../logic/providers/reflection_provider.dart';
import '../../widgets/bouncy_tap.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/pebble_mood_selector.dart';
import '../reflection/new_reflection_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final List<String> _categoryTabs = ['All', 'Mind', 'Career', 'Health', 'Routine'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final dateFormatted = DateFormat('EEEE, MMMM d').format(now);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => context.read<ReflectionProvider>().loadEntries(),
          color: AppColors.textPrimary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Dynamic iOS-Style Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateFormatted.toUpperCase(),
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
                                '${_getGreeting()}, Danish',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          // Search or Filter Action Button
                          BouncyTap(
                            onTap: () {
                              setState(() {
                                _isSearching = !_isSearching;
                                if (!_isSearching) {
                                  _searchController.clear();
                                  context.read<ReflectionProvider>().setSearchQuery('');
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceElevated
                                    : AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                  width: 0.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black26
                                        : AppColors.shadowColor,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isSearching
                                    ? Icons.close_rounded
                                    : Icons.search_rounded,
                                size: 20,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Take a breath. Capture the rhythm of your day.',
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

              // Search Bar (Expanded when active)
              if (_isSearching)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (val) =>
                          context.read<ReflectionProvider>().setSearchQuery(val),
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search reflections...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.textTertiary,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSurfaceElevated
                            : AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Quick Mood Check-in Card (5 Bouncing Pebble Glyphs)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(18),
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'QUICK MOOD CHECK-IN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.textTertiary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0x2210B981)
                                    : const Color(0x1810B981),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Tap pebble to log',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.moodGreat,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        PebbleMoodSelector(
                          selectedMood: null,
                          onMoodSelected: (mood) {
                            context.read<ReflectionProvider>().quickLogMood(mood);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logged ${mood.label} mood to your timeline.'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          showLabels: true,
                          pebbleSize: 48,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Category Filter Pills (Horizontal Scroll)
              SliverToBoxAdapter(
                child: Consumer<ReflectionProvider>(
                  builder: (context, provider, _) {
                    return SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _categoryTabs.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categoryTabs[index];
                          final isSelected = provider.selectedCategory == cat;

                          return BouncyTap(
                            onTap: () => provider.setCategory(cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary)
                                    : (isDark
                                        ? AppColors.darkSurfaceElevated
                                        : AppColors.surface),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (isDark
                                          ? AppColors.borderDark
                                          : AppColors.borderLight),
                                  width: 0.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: (isDark
                                                  ? Colors.white
                                                  : AppColors.textPrimary)
                                              .withOpacity(0.18),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark
                                          ? AppColors.darkBackground
                                          : Colors.white)
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Daily Log Feed
              Consumer<ReflectionProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CupertinoActivityIndicator(radius: 14),
                      ),
                    );
                  }

                  if (provider.entries.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceElevated
                                    : AppColors.cardSubtle,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.spa_outlined,
                                size: 36,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Reflections Yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button below to log your first mindful reflection.',
                              textAlign: TextAlign.center,
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
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = provider.entries[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ReflectionCard(entry: entry),
                          );
                        },
                        childCount: provider.entries.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  final EntryModel entry;

  const _ReflectionCard({required this.entry});

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'mind':
        return AppColors.catMind;
      case 'career':
        return AppColors.catCareer;
      case 'health':
        return AppColors.catHealth;
      case 'routine':
        return AppColors.catRoutine;
      default:
        return AppColors.catMind;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = _getCategoryColor(entry.category);

    return BouncyTap(
      onTap: () {
        NewReflectionSheet.show(context, existingEntry: entry);
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(18),
        borderRadius: 22,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header: Mood Pebble Dot + Category Pill + Timestamp + Favorite
            Row(
              children: [
                // Mood Pebble Dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: entry.mood.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: entry.mood.color.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  entry.mood.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: entry.mood.color,
                  ),
                ),
                const SizedBox(width: 10),
                // Category Tag Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    entry.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: catColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(entry.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                // Favorite Star
                BouncyTap(
                  onTap: () {
                    context.read<ReflectionProvider>().toggleFavorite(entry);
                  },
                  child: Icon(
                    entry.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 19,
                    color: entry.isFavorite
                        ? const Color(0xFFF59E0B)
                        : (isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary),
                  ),
                ),
                const SizedBox(width: 4),
                // Delete menu
                BouncyTap(
                  onTap: () {
                    _showCardActions(context, entry);
                  },
                  child: Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title (if present)
            if (entry.title.isNotEmpty) ...[
              Text(
                entry.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
            ],

            // Content
            Text(
              entry.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardActions(BuildContext context, EntryModel entry) {
    HapticService.light();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(entry.title.isNotEmpty ? entry.title : 'Reflection Actions'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              NewReflectionSheet.show(context, existingEntry: entry);
            },
            child: const Text('Edit Reflection'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ReflectionProvider>().deleteEntry(entry.id);
            },
            child: const Text('Delete'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pebble/core/services/haptic_service.dart';
import 'package:pebble/core/theme/app_colors.dart';
import 'package:pebble/data/models/entry_model.dart';
import 'package:pebble/logic/providers/reflection_provider.dart';
import 'package:pebble/presentation/widgets/bouncy_tap.dart';
import 'package:pebble/presentation/widgets/glass_container.dart';
import 'package:pebble/presentation/widgets/pebble_mood_selector.dart';

class NewReflectionSheet extends StatefulWidget {
  final EntryModel? existingEntry;

  const NewReflectionSheet({super.key, this.existingEntry});

  static Future<void> show(BuildContext context, {EntryModel? existingEntry}) {
    HapticService.light();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewReflectionSheet(existingEntry: existingEntry),
    );
  }

  @override
  State<NewReflectionSheet> createState() => _NewReflectionSheetState();
}

class _NewReflectionSheetState extends State<NewReflectionSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late MoodType _selectedMood;
  late String _selectedCategory;
  bool _isSubmitting = false;

  final List<String> _categories = ['Mind', 'Career', 'Health', 'Routine'];
  List<String> _prompts = [];
  String? _activePrompt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingEntry?.title ?? '');
    _contentController = TextEditingController(text: widget.existingEntry?.content ?? '');
    _selectedMood = widget.existingEntry?.mood ?? MoodType.good;
    _selectedCategory = widget.existingEntry?.category ?? 'Mind';
    _loadPrompts();
  }

  Future<void> _loadPrompts() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/prompts.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final list = (data['prompts'] as List)
          .map((p) => p['prompt'] as String)
          .toList();
      if (mounted) {
        setState(() {
          _prompts = list;
        });
      }
    } catch (_) {}
  }

  void _shufflePrompt() {
    if (_prompts.isEmpty) return;
    HapticService.selection();
    final remaining = _prompts.where((p) => p != _activePrompt).toList();
    remaining.shuffle();
    setState(() {
      _activePrompt = remaining.first;
      if (_titleController.text.isEmpty) {
        _titleController.text = _activePrompt!;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (content.isEmpty && title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a brief reflection note.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = context.read<ReflectionProvider>();
    final fallbackTitle = title.isEmpty
        ? 'Reflection on $_selectedCategory'
        : title;

    if (widget.existingEntry != null) {
      final updated = widget.existingEntry!.copyWith(
        title: fallbackTitle,
        content: content.isEmpty ? fallbackTitle : content,
        mood: _selectedMood,
        category: _selectedCategory,
      );
      await provider.updateEntry(updated);
    } else {
      await provider.createEntry(
        title: fallbackTitle,
        content: content.isEmpty ? fallbackTitle : content,
        mood: _selectedMood,
        category: _selectedCategory,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomInset + 20),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cupertino Top Grabber Bar
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingEntry == null
                        ? 'New Reflection'
                        : 'Edit Reflection',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  BouncyTap(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCardSubtle
                            : AppColors.cardSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Mood Selector Section
              Text(
                'HOW ARE YOU FEELING?',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                borderRadius: 20,
                child: Column(
                  children: [
                    PebbleMoodSelector(
                      selectedMood: _selectedMood,
                      onMoodSelected: (mood) => setState(() => _selectedMood = mood),
                      showLabels: true,
                      pebbleSize: 48,
                    ),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _selectedMood.description,
                        key: ValueKey(_selectedMood),
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: _selectedMood.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category Selector Pills
              Text(
                'SPHERE OF FOCUS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return BouncyTap(
                    onTap: () {
                      HapticService.selection();
                      setState(() => _selectedCategory = cat);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppColors.darkSurfaceElevated
                                : AppColors.textPrimary)
                            : (isDark
                                ? AppColors.darkCardSubtle
                                : AppColors.cardSubtle),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Colors.white24 : Colors.transparent)
                              : Colors.transparent,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Prompt Inspiration Generator Chip
              if (_prompts.isNotEmpty) ...[
                BouncyTap(
                  onTap: _shufflePrompt,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.catMind.withOpacity(0.15)
                          : AppColors.catMind.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.catMind.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 16,
                          color: AppColors.catMind,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _activePrompt ?? 'Tap for mindful reflection prompt',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.catMind,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.shuffle_rounded,
                          size: 15,
                          color: AppColors.catMind,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Title Field
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Reflection Title (optional)',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkCardSubtle
                      : AppColors.cardSubtle.withOpacity(0.5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Auto-expanding content field
              TextField(
                controller: _contentController,
                maxLines: 5,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'What is on your mind? Take a quiet breath and let thoughts flow...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkCardSubtle
                      : AppColors.cardSubtle.withOpacity(0.5),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Animated Save Action Button
              BouncyTap(
                onTap: _isSubmitting ? null : _handleSave,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.white : AppColors.textPrimary)
                            .withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _isSubmitting
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: isDark ? AppColors.textPrimary : Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.existingEntry == null
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.save_rounded,
                              size: 20,
                              color: isDark
                                  ? AppColors.textPrimary
                                  : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.existingEntry == null
                                  ? 'Save Reflection'
                                  : 'Update Reflection',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: isDark
                                  ? AppColors.textPrimary
                                  : Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

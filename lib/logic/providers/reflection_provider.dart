import 'package:flutter/foundation.dart';
import '../../core/services/haptic_service.dart';
import '../../data/models/entry_model.dart';
import '../../data/repositories/entry_repository.dart';

class ReflectionProvider extends ChangeNotifier {
  final EntryRepository _repository;

  List<EntryModel> _entries = [];
  String _selectedCategory = 'All';
  MoodType? _selectedMoodFilter;
  String _searchQuery = '';
  bool _favoritesOnly = false;
  bool _isLoading = true;

  ReflectionProvider({EntryRepository? repository})
      : _repository = repository ?? EntryRepository() {
    loadEntries();
  }

  List<EntryModel> get entries => _entries;
  String get selectedCategory => _selectedCategory;
  MoodType? get selectedMoodFilter => _selectedMoodFilter;
  String get searchQuery => _searchQuery;
  bool get favoritesOnly => _favoritesOnly;
  bool get isLoading => _isLoading;

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _repository.fetchEntries(
        category: _selectedCategory,
        mood: _selectedMoodFilter,
        query: _searchQuery,
        favoritesOnly: _favoritesOnly,
      );
    } catch (e) {
      debugPrint('Error loading entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    HapticService.selection();
    loadEntries();
  }

  void setMoodFilter(MoodType? mood) {
    if (_selectedMoodFilter == mood) {
      _selectedMoodFilter = null; // Toggle off
    } else {
      _selectedMoodFilter = mood;
    }
    HapticService.selection();
    loadEntries();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadEntries();
  }

  void toggleFavoritesOnly() {
    _favoritesOnly = !_favoritesOnly;
    HapticService.selection();
    loadEntries();
  }

  Future<void> createEntry({
    required String title,
    required String content,
    required MoodType mood,
    required String category,
  }) async {
    final newEntry = EntryModel(
      id: 'peb-${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      content: content.trim(),
      mood: mood,
      category: category,
      createdAt: DateTime.now(),
      isFavorite: false,
    );

    await _repository.addEntry(newEntry);
    await HapticService.medium();
    await loadEntries();
  }

  Future<void> quickLogMood(MoodType mood) async {
    final promptTitle = 'Quick Mood Check-in: ${mood.label}';
    final content = 'Captured a moment of awareness feeling ${mood.label.toLowerCase()} (${mood.description.toLowerCase()}).';
    
    await createEntry(
      title: promptTitle,
      content: content,
      mood: mood,
      category: 'Mind',
    );
  }

  Future<void> updateEntry(EntryModel entry) async {
    await _repository.updateEntry(entry);
    await HapticService.light();
    await loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.removeEntry(id);
    await HapticService.heavy();
    await loadEntries();
  }

  Future<void> toggleFavorite(EntryModel entry) async {
    await _repository.toggleFavorite(entry.id, entry.isFavorite);
    await HapticService.light();
    await loadEntries();
  }

  Future<String> exportData() async {
    return await _repository.exportBackupJson();
  }

  Future<void> resetAllData() async {
    await _repository.clearAllData();
    await HapticService.heavy();
    await loadEntries();
  }
}

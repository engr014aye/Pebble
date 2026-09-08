import '../../core/database/db_helper.dart';
import '../models/entry_model.dart';

class EntryRepository {
  final DBHelper _dbHelper;

  EntryRepository({DBHelper? dbHelper}) : _dbHelper = dbHelper ?? DBHelper.instance;

  Future<List<EntryModel>> fetchEntries({
    String? category,
    MoodType? mood,
    String? query,
    bool? favoritesOnly,
  }) {
    return _dbHelper.getEntries(
      category: category,
      mood: mood,
      query: query,
      favoritesOnly: favoritesOnly,
    );
  }

  Future<void> addEntry(EntryModel entry) {
    return _dbHelper.insertEntry(entry);
  }

  Future<void> updateEntry(EntryModel entry) {
    return _dbHelper.updateEntry(entry);
  }

  Future<void> removeEntry(String id) {
    return _dbHelper.deleteEntry(id);
  }

  Future<void> toggleFavorite(String id, bool currentStatus) {
    return _dbHelper.toggleFavorite(id, currentStatus);
  }

  Future<List<MoodMetric>> getWeeklyMoodMetrics() {
    return _dbHelper.getWeeklyMoodMetrics();
  }

  Future<int> getStreakCount() {
    return _dbHelper.calculateStreak();
  }

  Future<Map<String, int>> getCategoryCounts() {
    return _dbHelper.getCategoryCounts();
  }

  Future<Map<MoodType, int>> getMoodDistribution() {
    return _dbHelper.getMoodDistribution();
  }

  Future<String> exportBackupJson() {
    return _dbHelper.exportAllDataAsJson();
  }

  Future<void> clearAllData() {
    return _dbHelper.resetDatabase();
  }
}

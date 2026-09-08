import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/entry_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pebble_store.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries (
        id TEXT PRIMARY KEY,
        title TEXT,
        content TEXT NOT NULL,
        mood TEXT NOT NULL,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color_hex TEXT NOT NULL
      )
    ''');

    // Populate initial categories
    final initialCategories = [
      {'id': '1', 'name': 'Mind', 'color_hex': '6366F1'},
      {'id': '2', 'name': 'Career', 'color_hex': '0284C7'},
      {'id': '3', 'name': 'Health', 'color_hex': '10B981'},
      {'id': '4', 'name': 'Routine', 'color_hex': 'D97706'},
    ];
    for (final cat in initialCategories) {
      await db.insert('categories', cat);
    }

    // Seed realistic Apple-grade introductory reflections
    final now = DateTime.now();
    final seedEntries = [
      EntryModel(
        id: 'seed-1',
        title: 'Morning stillness in the courtyard',
        content: 'Sat with warm tea before the emails and messages arrived. Observed the light shifting across the lime-washed walls. Mind felt quiet and spacious.',
        mood: MoodType.great,
        category: 'Mind',
        createdAt: now.subtract(const Duration(hours: 4)),
        isFavorite: true,
      ),
      EntryModel(
        id: 'seed-2',
        title: 'Deep architecture work',
        content: 'Refactored the primary workflow engine. Clean, concise, decoupled logic. Finding simplicity in complex systems is immensely satisfying.',
        mood: MoodType.good,
        category: 'Career',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        isFavorite: false,
      ),
      EntryModel(
        id: 'seed-3',
        title: 'Dusk jog by the river',
        content: 'Brisk 5km pace under autumn skies. Heart rate up, lingering tension dissipated. Feeling restored and grounded.',
        mood: MoodType.great,
        category: 'Health',
        createdAt: now.subtract(const Duration(days: 2, hours: 5)),
        isFavorite: true,
      ),
      EntryModel(
        id: 'seed-4',
        title: 'Pacing through an uninspired afternoon',
        content: 'Felt a dip in momentum after lunch. Resisted the urge to force productivity; instead took a ten-minute breath walk and reset my focus.',
        mood: MoodType.neutral,
        category: 'Routine',
        createdAt: now.subtract(const Duration(days: 3, hours: 3)),
        isFavorite: false,
      ),
      EntryModel(
        id: 'seed-5',
        title: 'Early meditation & journaling',
        content: 'Wrote down three things I often take for granted. Grateful for quiet mornings and clear air.',
        mood: MoodType.good,
        category: 'Mind',
        createdAt: now.subtract(const Duration(days: 4, hours: 6)),
        isFavorite: false,
      ),
    ];

    for (final entry in seedEntries) {
      await db.insert('entries', entry.toMap());
    }
  }

  // --- CRUD Operations ---

  Future<int> insertEntry(EntryModel entry) async {
    final db = await instance.database;
    return await db.insert(
      'entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<EntryModel>> getEntries({
    String? category,
    MoodType? mood,
    String? query,
    bool? favoritesOnly,
  }) async {
    final db = await instance.database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (category != null && category != 'All') {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    if (mood != null) {
      whereClauses.add('mood = ?');
      whereArgs.add(mood.label);
    }

    if (favoritesOnly == true) {
      whereClauses.add('is_favorite = 1');
    }

    if (query != null && query.trim().isNotEmpty) {
      whereClauses.add('(title LIKE ? OR content LIKE ?)');
      whereArgs.add('%$query%');
      whereArgs.add('%$query%');
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final result = await db.query(
      'entries',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
    );

    return result.map((map) => EntryModel.fromMap(map)).toList();
  }

  Future<int> updateEntry(EntryModel entry) async {
    final db = await instance.database;
    return await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(String id) async {
    final db = await instance.database;
    return await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavorite(String id, bool currentStatus) async {
    final db = await instance.database;
    return await db.update(
      'entries',
      {'is_favorite': currentStatus ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Analytics & Streak Computation ---

  Future<List<MoodMetric>> getWeeklyMoodMetrics() async {
    final db = await instance.database;
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    final startDateStr = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day).toIso8601String();

    final result = await db.rawQuery('''
      SELECT 
        substr(created_at, 1, 10) as day_date,
        mood
      FROM entries
      WHERE created_at >= ?
      ORDER BY created_at ASC
    ''', [startDateStr]);

    // Aggregate by day
    final Map<String, List<int>> dailyScores = {};
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      dailyScores[key] = [];
    }

    for (final row in result) {
      final day = row['day_date'] as String;
      final moodStr = row['mood'] as String;
      final score = MoodType.fromString(moodStr).score;
      if (dailyScores.containsKey(day)) {
        dailyScores[day]!.add(score);
      }
    }

    return dailyScores.entries.map((e) {
      final scores = e.value;
      final avg = scores.isEmpty ? 3.0 : (scores.reduce((a, b) => a + b) / scores.length);
      return MoodMetric(
        date: e.key,
        averageScore: avg,
        count: scores.length,
      );
    }).toList();
  }

  Future<int> calculateStreak() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT DISTINCT substr(created_at, 1, 10) as entry_day
      FROM entries
      ORDER BY entry_day DESC
    ''');

    if (result.isEmpty) return 0;

    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    final days = result.map((r) => r['entry_day'] as String).toList();
    if (!days.contains(todayStr) && !days.contains(yesterdayStr)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = days.contains(todayStr) ? today : yesterday;

    while (true) {
      final checkStr = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      if (days.contains(checkStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Future<Map<String, int>> getCategoryCounts() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT category, COUNT(*) as cnt
      FROM entries
      GROUP BY category
    ''');
    final Map<String, int> counts = {};
    for (final row in result) {
      counts[row['category'] as String] = row['cnt'] as int;
    }
    return counts;
  }

  Future<Map<MoodType, int>> getMoodDistribution() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT mood, COUNT(*) as cnt
      FROM entries
      GROUP BY mood
    ''');
    final Map<MoodType, int> counts = {
      MoodType.great: 0,
      MoodType.good: 0,
      MoodType.neutral: 0,
      MoodType.low: 0,
      MoodType.tough: 0,
    };
    for (final row in result) {
      final mood = MoodType.fromString(row['mood'] as String);
      counts[mood] = (row['cnt'] as int);
    }
    return counts;
  }

  Future<String> exportAllDataAsJson() async {
    final db = await instance.database;
    final entries = await db.query('entries', orderBy: 'created_at ASC');
    final exportMap = {
      'app': 'Pebble',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'total_entries': entries.length,
      'entries': entries,
    };
    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  Future<void> resetDatabase() async {
    final db = await instance.database;
    await db.delete('entries');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}

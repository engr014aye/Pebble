import 'package:flutter/foundation.dart';
import '../../data/models/entry_model.dart';
import '../../data/repositories/entry_repository.dart';

class AnalyticsProvider extends ChangeNotifier {
  final EntryRepository _repository;

  List<MoodMetric> _weeklyMetrics = [];
  int _streak = 0;
  Map<String, int> _categoryCounts = {};
  Map<MoodType, int> _moodDistribution = {};
  bool _isLoading = true;

  AnalyticsProvider({EntryRepository? repository})
      : _repository = repository ?? EntryRepository() {
    refreshAnalytics();
  }

  List<MoodMetric> get weeklyMetrics => _weeklyMetrics;
  int get streak => _streak;
  Map<String, int> get categoryCounts => _categoryCounts;
  Map<MoodType, int> get moodDistribution => _moodDistribution;
  bool get isLoading => _isLoading;

  int get totalEntries => _moodDistribution.values.fold(0, (a, b) => a + b);

  double get averageWeeklyScore {
    if (_weeklyMetrics.isEmpty) return 0.0;
    final validMetrics = _weeklyMetrics.where((m) => m.count > 0).toList();
    if (validMetrics.isEmpty) return 0.0;
    final sum = validMetrics.map((m) => m.averageScore).reduce((a, b) => a + b);
    return sum / validMetrics.length;
  }

  Future<void> refreshAnalytics() async {
    _isLoading = true;
    notifyListeners();

    try {
      _weeklyMetrics = await _repository.getWeeklyMoodMetrics();
      _streak = await _repository.getStreakCount();
      _categoryCounts = await _repository.getCategoryCounts();
      _moodDistribution = await _repository.getMoodDistribution();
    } catch (e) {
      debugPrint('Error refreshing analytics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

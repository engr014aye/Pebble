import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum MoodType {
  great(5, 'Great', 'Inspired & Calm', AppColors.moodGreat),
  good(4, 'Good', 'Positive & Centered', AppColors.moodGood),
  neutral(3, 'Neutral', 'Quiet & Balanced', AppColors.moodNeutral),
  low(2, 'Low', 'Subdued & Weary', AppColors.moodLow),
  tough(1, 'Tough', 'Heavy & Strained', AppColors.moodTough);

  final int score;
  final String label;
  final String description;
  final Color color;

  const MoodType(this.score, this.label, this.description, this.color);

  static MoodType fromString(String name) {
    switch (name.trim().toLowerCase()) {
      case 'great':
        return MoodType.great;
      case 'good':
        return MoodType.good;
      case 'neutral':
        return MoodType.neutral;
      case 'low':
        return MoodType.low;
      case 'tough':
        return MoodType.tough;
      default:
        return MoodType.good;
    }
  }

  static MoodType fromScore(int score) {
    switch (score) {
      case 5:
        return MoodType.great;
      case 4:
        return MoodType.good;
      case 3:
        return MoodType.neutral;
      case 2:
        return MoodType.low;
      case 1:
        return MoodType.tough;
      default:
        return MoodType.good;
    }
  }
}

class EntryModel {
  final String id;
  final String title;
  final String content;
  final MoodType mood;
  final String category;
  final DateTime createdAt;
  final bool isFavorite;

  const EntryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.category,
    required this.createdAt,
    this.isFavorite = false,
  });

  EntryModel copyWith({
    String? id,
    String? title,
    String? content,
    MoodType? mood,
    String? category,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return EntryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood.label,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory EntryModel.fromMap(Map<String, dynamic> map) {
    return EntryModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      mood: MoodType.fromString(map['mood'] as String? ?? 'Good'),
      category: map['category'] as String? ?? 'Mind',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory EntryModel.fromJson(Map<String, dynamic> json) => EntryModel.fromMap(json);
}

class MoodMetric {
  final String date; // YYYY-MM-DD
  final double averageScore;
  final int count;

  const MoodMetric({
    required this.date,
    required this.averageScore,
    required this.count,
  });

  factory MoodMetric.fromMap(Map<String, dynamic> map) {
    return MoodMetric(
      date: map['date'] as String,
      averageScore: (map['average_score'] as num?)?.toDouble() ?? 3.0,
      count: (map['count'] as int?) ?? 1,
    );
  }
}

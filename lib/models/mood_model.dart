import 'package:flutter/material.dart';

enum MoodLevel {
  veryBad,
  bad,
  neutral,
  good,
  veryGood
}

class MoodEntry {
  final String id;
  final DateTime timestamp;
  final MoodLevel moodLevel;
  final String? note;
  final List<String> tags;

  MoodEntry({
    required this.id,
    required this.timestamp,
    required this.moodLevel,
    this.note,
    this.tags = const [],
  });

  // Convert MoodEntry to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'moodLevel': moodLevel.index,
      'note': note,
      'tags': tags,
    };
  }

  // Create a MoodEntry from a map
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      moodLevel: MoodLevel.values[map['moodLevel']],
      note: map['note'],
      tags: List<String>.from(map['tags']),
    );
  }
}

// Helper function to get an icon for a mood level
IconData getMoodIcon(MoodLevel mood) {
  switch (mood) {
    case MoodLevel.veryBad:
      return Icons.sentiment_very_dissatisfied;
    case MoodLevel.bad:
      return Icons.sentiment_dissatisfied;
    case MoodLevel.neutral:
      return Icons.sentiment_neutral;
    case MoodLevel.good:
      return Icons.sentiment_satisfied;
    case MoodLevel.veryGood:
      return Icons.sentiment_very_satisfied;
  }
}

// Helper function to get a descriptive label for a mood level
String getMoodLabel(MoodLevel mood) {
  switch (mood) {
    case MoodLevel.veryBad:
      return "Very Bad";
    case MoodLevel.bad:
      return "Bad";
    case MoodLevel.neutral:
      return "Okay";
    case MoodLevel.good:
      return "Good";
    case MoodLevel.veryGood:
      return "Very Good";
  }
} 
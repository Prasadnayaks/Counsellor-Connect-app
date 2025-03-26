import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'mood_entry.dart';
import '../services/firebase_service.dart';
import '../providers/achievement_provider.dart';

class MoodProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final AchievementProvider? _achievementProvider;
  List<MoodEntry> _moodEntries = [];
  bool _isLoading = true;
  int _currentStreak = 0;

  MoodProvider(
      this._firebaseService, {
        AchievementProvider? achievementProvider,
      }) : _achievementProvider = achievementProvider {
    _loadMoodEntries();
  }

  List<MoodEntry> get moodEntries => _moodEntries;
  bool get isLoading => _isLoading;
  int get currentStreak => _currentStreak;

  Future<void> _loadMoodEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _moodEntries = await _firebaseService.getAllMoodEntries();
      _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _calculateStreak();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading mood entries: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMoodEntry(String mood, String note) async {
    try {
      final entry = MoodEntry(
        id: const Uuid().v4(),
        mood: mood,
        note: note,
        timestamp: DateTime.now(),
      );

      await _firebaseService.saveMoodEntry(entry);
      await _loadMoodEntries();

      // Check for achievements if achievement provider exists
      _achievementProvider?.checkMoodAchievements(
        _moodEntries.length,
        _currentStreak,
      );
    } catch (e) {
      debugPrint('Error adding mood entry: $e');
    }
  }

  Future<void> deleteMoodEntry(String id) async {
    try {
      await _firebaseService.deleteMoodEntry(id);
      await _loadMoodEntries();
    } catch (e) {
      debugPrint('Error deleting mood entry: $e');
    }
  }

  void _calculateStreak() {
    if (_moodEntries.isEmpty) {
      _currentStreak = 0;
      return;
    }

    // Sort entries by date (newest first)
    _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Check if there's an entry for today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final latestEntry = _moodEntries.first;
    final latestEntryDate = DateTime(
      latestEntry.timestamp.year,
      latestEntry.timestamp.month,
      latestEntry.timestamp.day,
    );

    // If no entry for today, streak might be broken
    if (latestEntryDate.isBefore(today)) {
      final yesterday = today.subtract(const Duration(days: 1));

      // If the latest entry is not from yesterday, streak is broken
      if (latestEntryDate.isBefore(yesterday)) {
        _currentStreak = 0;
        return;
      }
    }

    // Count consecutive days
    _currentStreak = 1; // Start with today or the latest day
    DateTime previousDate = latestEntryDate;

    for (int i = 1; i < _moodEntries.length; i++) {
      final entry = _moodEntries[i];
      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      // If this entry is from the day before the previous entry, increment streak
      final expectedPreviousDay = previousDate.subtract(const Duration(days: 1));

      if (entryDate.year == expectedPreviousDay.year &&
          entryDate.month == expectedPreviousDay.month &&
          entryDate.day == expectedPreviousDay.day) {
        _currentStreak++;
        previousDate = entryDate;
      } else {
        // Streak is broken
        break;
      }
    }
  }

  List<MoodEntry> getMoodEntriesForDay(DateTime date) {
    return _moodEntries.where((entry) {
      return entry.timestamp.year == date.year &&
          entry.timestamp.month == date.month &&
          entry.timestamp.day == date.day;
    }).toList();
  }

  List<MoodEntry> getMoodEntriesForRange(DateTime start, DateTime end) {
    return _moodEntries.where((entry) {
      return entry.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
          entry.timestamp.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  Map<String, int> getMoodDistribution() {
    final distribution = <String, int>{};

    for (var entry in _moodEntries) {
      distribution[entry.mood] = (distribution[entry.mood] ?? 0) + 1;
    }

    return distribution;
  }
}


import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/cbt_session.dart';
import '../services/firebase_service.dart';
import 'achievement_provider.dart';

class CBTProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final AchievementProvider _achievementProvider;
  List<CBTSession> _sessions = [];
  bool _isLoading = true;

  CBTProvider(
      this._firebaseService, {
        required AchievementProvider achievementProvider,
      }) : _achievementProvider = achievementProvider {
    _loadSessions();
  }

  bool get isLoading => _isLoading;
  List<CBTSession> get allSessions => _sessions;

  List<CBTSession> get recentSessions {
    final sortedSessions = List<CBTSession>.from(_sessions);
    sortedSessions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return sortedSessions.take(5).toList();
  }

  int get currentStreak {
    if (_sessions.isEmpty) return 0;

    // Sort sessions by date (newest first)
    final sortedSessions = List<CBTSession>.from(_sessions);
    sortedSessions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // Calculate streak
    int streak = 1;
    DateTime lastDate = sortedSessions[0].dateTime;
    DateTime today = DateTime.now();

    // Check if the most recent session is from today or yesterday
    if (lastDate.difference(DateTime(today.year, today.month, today.day)).inDays < -1) {
      return 0; // Streak broken
    }

    // Count consecutive days
    for (int i = 1; i < sortedSessions.length; i++) {
      final currentDate = sortedSessions[i].dateTime;
      final difference = lastDate.difference(currentDate).inDays;

      if (difference == 1) {
        // Consecutive day
        streak++;
        lastDate = currentDate;
      } else if (difference > 1) {
        // Streak broken
        break;
      }
    }

    return streak;
  }

  String get mostUsedTechnique {
    if (_sessions.isEmpty) return 'None';

    // Count techniques
    final techniqueCounts = <String, int>{};
    for (var session in _sessions) {
      techniqueCounts[session.technique] = (techniqueCounts[session.technique] ?? 0) + 1;
    }

    // Find most used
    String mostUsed = 'None';
    int highestCount = 0;

    techniqueCounts.forEach((technique, count) {
      if (count > highestCount) {
        mostUsed = technique;
        highestCount = count;
      }
    });

    // Format the technique name
    return _formatTechniqueName(mostUsed);
  }

  Future<void> _loadSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sessions = await _firebaseService.getAllCBTSessions();
      _sessions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading CBT sessions: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSession({
    required String title,
    required String technique,
    required Map<String, dynamic> data,
    required int durationMinutes,
    required String notes,
    required String insights,
  }) async {
    try {
      final session = CBTSession(
        id: const Uuid().v4(),
        title: title,
        technique: technique,
        data: data,
        dateTime: DateTime.now(),
        userId: _firebaseService.currentUserId,
        durationMinutes: durationMinutes,
        notes: notes,
        insights: insights,
      );

      await _firebaseService.saveCBTSession(session);

      // Check for achievements
      await _checkAchievements();

      await _loadSessions();
    } catch (e) {
      debugPrint('Error saving CBT session: $e');
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      await _firebaseService.deleteCBTSession(id);
      await _loadSessions();
    } catch (e) {
      debugPrint('Error deleting CBT session: $e');
    }
  }

  Future<void> _checkAchievements() async {
    // First CBT session
    if (_sessions.length == 1) {
      await _achievementProvider.unlockAchievement('first_cbt_session');
    }

    // 5 CBT sessions
    if (_sessions.length == 5) {
      await _achievementProvider.unlockAchievement('five_cbt_sessions');
    }

    // 10 CBT sessions
    if (_sessions.length == 10) {
      await _achievementProvider.unlockAchievement('ten_cbt_sessions');
    }

    // 3-day streak
    if (currentStreak == 3) {
      await _achievementProvider.unlockAchievement('three_day_cbt_streak');
    }

    // 7-day streak
    if (currentStreak == 7) {
      await _achievementProvider.unlockAchievement('seven_day_cbt_streak');
    }
  }

  String _formatTechniqueName(String technique) {
    switch (technique) {
      case 'thought_record':
        return 'Thought Record';
      case 'cognitive_restructuring':
        return 'Cognitive Restructuring';
      case 'behavioral_activation':
        return 'Behavioral Activation';
      case 'problem_solving':
        return 'Problem Solving';
      default:
        return technique.split('_').map((word) =>
        word.substring(0, 1).toUpperCase() + word.substring(1)
        ).join(' ');
    }
  }

  void addSession({required String technique, required int durationMinutes, required String notes, required String insights}) {}
}


import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/achievement.dart';
import '../services/firebase_service.dart';

class AchievementProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  List<Achievement> _achievements = [];
  bool _isLoading = true;
  int _totalPoints = 0;

  AchievementProvider(this._firebaseService) {
    _loadAchievements();
  }

  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  int get totalPoints => _totalPoints;

  get allAchievements => null;

  get unlockedAchievements => null;

  Future<void> _loadAchievements() async {
    _isLoading = true;
    notifyListeners();

    try {
      _achievements = await _firebaseService.getAllAchievements();
      _calculateTotalPoints();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading achievements: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateTotalPoints() {
    _totalPoints = _achievements
        .where((achievement) => achievement.isUnlocked)
        .fold(0, (sum, achievement) => sum + achievement.points);
  }

  Future<void> unlockAchievement(String achievementId) async {
    try {
      final achievementIndex = _achievements.indexWhere((a) => a.id == achievementId);
      if (achievementIndex != -1) {
        final achievement = _achievements[achievementIndex];
        if (!achievement.isUnlocked) {
          final updatedAchievement = Achievement(
            id: achievement.id,
            title: achievement.title,
            description: achievement.description,
            category: achievement.category,
            points: achievement.points,
            iconPath: achievement.iconPath,
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            criteria: achievement.criteria,
            progress: achievement.targetValue,
            targetValue: achievement.targetValue,
          );

          await _firebaseService.saveAchievement(updatedAchievement);
          await _loadAchievements();
        }
      }
    } catch (e) {
      debugPrint('Error unlocking achievement: $e');
    }
  }

  Future<void> updateAchievementProgress(String achievementId, int progress) async {
    try {
      final achievementIndex = _achievements.indexWhere((a) => a.id == achievementId);
      if (achievementIndex != -1) {
        final achievement = _achievements[achievementIndex];

        // Check if achievement should be unlocked
        final shouldUnlock = progress >= achievement.targetValue && !achievement.isUnlocked;

        final updatedAchievement = Achievement(
          id: achievement.id,
          title: achievement.title,
          description: achievement.description,
          category: achievement.category,
          points: achievement.points,
          iconPath: achievement.iconPath,
          isUnlocked: shouldUnlock ? true : achievement.isUnlocked,
          unlockedAt: shouldUnlock ? DateTime.now() : achievement.unlockedAt,
          criteria: achievement.criteria,
          progress: progress,
          targetValue: achievement.targetValue,
        );

        await _firebaseService.saveAchievement(updatedAchievement);
        await _loadAchievements();
      }
    } catch (e) {
      debugPrint('Error updating achievement progress: $e');
    }
  }

  // Check for mood-related achievements
  void checkMoodAchievements(int totalEntries, int streak) {
    try {
      for (var achievement in _achievements.where((a) => a.category == 'mood')) {
        if (achievement.isUnlocked) continue;

        if (achievement.criteria.containsKey('totalEntries')) {
          final requiredEntries = achievement.criteria['totalEntries'] as int;
          if (totalEntries >= requiredEntries) {
            unlockAchievement(achievement.id);
          } else {
            updateAchievementProgress(achievement.id, totalEntries);
          }
        }

        if (achievement.criteria.containsKey('streak')) {
          final requiredStreak = achievement.criteria['streak'] as int;
          if (streak >= requiredStreak) {
            unlockAchievement(achievement.id);
          } else {
            updateAchievementProgress(achievement.id, streak);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking mood achievements: $e');
    }
  }

  // Check for journal-related achievements
  void checkJournalAchievements(int totalEntries) {
    try {
      for (var achievement in _achievements.where((a) => a.category == 'journal')) {
        if (achievement.isUnlocked) continue;

        if (achievement.criteria.containsKey('totalEntries')) {
          final requiredEntries = achievement.criteria['totalEntries'] as int;
          if (totalEntries >= requiredEntries) {
            unlockAchievement(achievement.id);
          } else {
            updateAchievementProgress(achievement.id, totalEntries);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking journal achievements: $e');
    }
  }

  // Check for CBT-related achievements
  void checkCBTAchievements(int totalSessions, int streak, String? mostUsedTechnique) {
    try {
      for (var achievement in _achievements.where((a) => a.category == 'cbt')) {
        if (achievement.isUnlocked) continue;

        if (achievement.criteria.containsKey('totalSessions')) {
          final requiredSessions = achievement.criteria['totalSessions'] as int;
          if (totalSessions >= requiredSessions) {
            unlockAchievement(achievement.id);
          } else {
            updateAchievementProgress(achievement.id, totalSessions);
          }
        }

        if (achievement.criteria.containsKey('streak')) {
          final requiredStreak = achievement.criteria['streak'] as int;
          if (streak >= requiredStreak) {
            unlockAchievement(achievement.id);
          } else {
            updateAchievementProgress(achievement.id, streak);
          }
        }

        if (achievement.criteria.containsKey('technique') && mostUsedTechnique != null) {
          final requiredTechnique = achievement.criteria['technique'] as String;
          if (mostUsedTechnique == requiredTechnique) {
            unlockAchievement(achievement.id);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking CBT achievements: $e');
    }
  }

  // Check for goal-related achievements
  void checkGoalAchievements(int totalGoals, int completedGoals) {
    try {
      for (var achievement in _achievements.where((a) => a.category == 'goal')) {
        if (achievement.isUnlocked) continue;

        if (achievement.criteria.containsKey('totalGoals')) {
          final requiredGoals = achievement.criteria['totalGoals'] as int;
          if (totalGoals >= requiredGoals) {
            unlockAchievement(achievement.id);
          } else {
            updateAchievementProgress(achievement.id, totalGoals);
          }
        }

        if (achievement.criteria.containsKey('completedGoals')) {
          final requiredCompletedGoals = achievement.criteria['completedGoals'] as int;
          if (completedGoals >= requiredCompletedGoals) {
            unlockAchievement(achievement.id);
          } else {
            updateAchievementProgress(achievement.id, completedGoals);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking goal achievements: $e');
    }
  }

  // Get total points
  int getTotalPoints() {
    return _totalPoints;
  }
}


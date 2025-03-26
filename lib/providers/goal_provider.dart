import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../services/firebase_service.dart';
import 'notification_provider.dart';
import 'achievement_provider.dart';

class GoalProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final NotificationProvider? _notificationProvider;
  final AchievementProvider? _achievementProvider;
  List<Goal> _goals = [];
  List<Milestone> _milestones = [];
  bool _isLoading = true;

  GoalProvider(
      this._firebaseService, {
        NotificationProvider? notificationProvider,
        AchievementProvider? achievementProvider,
      }) :
        _notificationProvider = notificationProvider,
        _achievementProvider = achievementProvider {
    _loadData();
  }

  List<Goal> get goals => _goals;
  List<Milestone> get milestones => _milestones;
  bool get isLoading => _isLoading;

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadGoals(),
        _loadMilestones(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading goal data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadGoals() async {
    try {
      _goals = await _firebaseService.getAllGoals();
      _goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading goals: $e');
    }
  }

  Future<void> _loadMilestones() async {
    try {
      _milestones = await _firebaseService.getAllMilestones();
    } catch (e) {
      debugPrint('Error loading milestones: $e');
    }
  }

  Future<void> addGoal({
    required String title,
    required String description,
    required DateTime targetDate,
    required String category,
    List<String> milestones = const [],
  }) async {
    try {
      final goalId = const Uuid().v4();

      final goal = Goal(
        id: goalId,
        title: title,
        description: description,
        createdAt: DateTime.now(),
        targetDate: targetDate,
        category: category,
      );

      await _firebaseService.saveGoal(goal);

      // Add milestones if provided
      for (var milestoneTitle in milestones) {
        await addMilestone(
          goalId: goalId,
          title: milestoneTitle,
        );
      }

      // Create notification for new goal if notification provider exists
      _notificationProvider?.addNotification(
        title: 'New Goal Created',
        body: 'You\'ve set a new goal: $title',
        type: 'goal',
        referenceId: goalId, userId: '',
      );

      // Check for goal achievements if achievement provider exists
      _achievementProvider?.checkGoalAchievements(
        _goals.length + 1, // Including the new goal
        _goals.where((g) => g.isCompleted).length,
      );

      await _loadData();
    } catch (e) {
      debugPrint('Error adding goal: $e');
    }
  }

  Future<void> addMilestone({
    required String goalId,
    required String title,
  }) async {
    try {
      final milestone = Milestone(
        id: const Uuid().v4(),
        goalId: goalId,
        title: title,
      );

      await _firebaseService.saveMilestone(milestone);

      // Update goal with milestone ID
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex != -1) {
        final goal = _goals[goalIndex];
        final updatedMilestoneIds = List<String>.from(goal.milestoneIds)..add(milestone.id);

        final updatedGoal = Goal(
          id: goal.id,
          title: goal.title,
          description: goal.description,
          createdAt: goal.createdAt,
          targetDate: goal.targetDate,
          milestoneIds: updatedMilestoneIds,
          isCompleted: goal.isCompleted,
          category: goal.category,
        );

        await _firebaseService.saveGoal(updatedGoal);
      }

      await _loadData();
    } catch (e) {
      debugPrint('Error adding milestone: $e');
    }
  }

  Future<void> completeMilestone(String milestoneId) async {
    try {
      final milestoneIndex = _milestones.indexWhere((m) => m.id == milestoneId);
      if (milestoneIndex != -1) {
        final milestone = _milestones[milestoneIndex];
        final updatedMilestone = Milestone(
          id: milestone.id,
          goalId: milestone.goalId,
          title: milestone.title,
          isCompleted: true,
          completedAt: DateTime.now(),
        );

        await _firebaseService.saveMilestone(updatedMilestone);

        // Check if all milestones for this goal are completed
        await _checkGoalCompletion(milestone.goalId);

        await _loadData();
      }
    } catch (e) {
      debugPrint('Error completing milestone: $e');
    }
  }

  Future<void> _checkGoalCompletion(String goalId) async {
    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex != -1) {
        final goal = _goals[goalIndex];
        final goalMilestones = _milestones.where((m) => m.goalId == goalId).toList();

        final allCompleted = goalMilestones.isNotEmpty &&
            goalMilestones.every((m) => m.isCompleted);

        if (allCompleted && !goal.isCompleted) {
          final updatedGoal = Goal(
            id: goal.id,
            title: goal.title,
            description: goal.description,
            createdAt: goal.createdAt,
            targetDate: goal.targetDate,
            milestoneIds: goal.milestoneIds,
            isCompleted: true,
            category: goal.category,
          );

          await _firebaseService.saveGoal(updatedGoal);

          // Create notification for completed goal if notification provider exists
          _notificationProvider?.addNotification(
            title: 'Goal Completed!',
            body: 'Congratulations! You\'ve completed your goal: ${goal.title}',
            type: 'goal',
            referenceId: goal.id, userId: '',
          );

          // Check for goal achievements if achievement provider exists
          _achievementProvider?.checkGoalAchievements(
            _goals.length,
            _goals.where((g) => g.isCompleted).length + 1, // Including the newly completed goal
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking goal completion: $e');
    }
  }

  Future<void> completeGoal(String goalId) async {
    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex != -1) {
        final goal = _goals[goalIndex];
        final updatedGoal = Goal(
          id: goal.id,
          title: goal.title,
          description: goal.description,
          createdAt: goal.createdAt,
          targetDate: goal.targetDate,
          milestoneIds: goal.milestoneIds,
          isCompleted: true,
          category: goal.category,
        );

        await _firebaseService.saveGoal(updatedGoal);

        // Create notification for completed goal if notification provider exists
        _notificationProvider?.addNotification(
          title: 'Goal Completed!',
          body: 'Congratulations! You\'ve completed your goal: ${goal.title}',
          type: 'goal',
          referenceId: goal.id, userId: '',
        );

        // Check for goal achievements if achievement provider exists
        _achievementProvider?.checkGoalAchievements(
          _goals.length,
          _goals.where((g) => g.isCompleted).length + 1, // Including the newly completed goal
        );

        await _loadData();
      }
    } catch (e) {
      debugPrint('Error completing goal: $e');
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      // Delete all milestones for this goal
      final goalMilestones = _milestones.where((m) => m.goalId == goalId).toList();
      for (var milestone in goalMilestones) {
        await _firebaseService.deleteMilestone(milestone.id);
      }

      await _firebaseService.deleteGoal(goalId);
      await _loadData();
    } catch (e) {
      debugPrint('Error deleting goal: $e');
    }
  }

  List<Goal> getGoalsByCategory(String category) {
    return _goals.where((g) => g.category == category).toList();
  }

  List<Goal> getActiveGoals() {
    return _goals.where((g) => !g.isCompleted).toList();
  }

  List<Goal> getCompletedGoals() {
    return _goals.where((g) => g.isCompleted).toList();
  }

  List<Milestone> getMilestonesForGoal(String goalId) {
    return _milestones.where((m) => m.goalId == goalId).toList();
  }
}


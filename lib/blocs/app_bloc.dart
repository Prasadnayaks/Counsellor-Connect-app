import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../models/user_model.dart';
//import '../database_service.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';

// Main app state management using BLoC pattern
class AppBloc {
  //final DatabaseService _databaseService;
  final NotificationService _notificationService;
  final AnalyticsService _analyticsService;

  // State controllers
  final _themeController = BehaviorSubject<ThemeMode>.seeded(ThemeMode.system);
  final _userController = BehaviorSubject<UserModel?>();
  final _isLoadingController = BehaviorSubject<bool>.seeded(false);
  final _errorController = BehaviorSubject<String?>.seeded(null);
  final _streakController = BehaviorSubject<int>.seeded(0);
  final _achievementsController = BehaviorSubject<int>.seeded(0);

  // Streams
  Stream<ThemeMode> get themeStream => _themeController.stream;
  Stream<UserModel?> get userStream => _userController.stream;
  Stream<bool> get isLoadingStream => _isLoadingController.stream;
  Stream<String?> get errorStream => _errorController.stream;
  Stream<int> get streakStream => _streakController.stream;
  Stream<int> get achievementsStream => _achievementsController.stream;

  // Current values
  ThemeMode get currentTheme => _themeController.value;
  UserModel? get currentUser => _userController.value;
  bool get isLoading => _isLoadingController.value;
  String? get error => _errorController.value;
  int get currentStreak => _streakController.value;
  int get achievementsCount => _achievementsController.value;

  AppBloc(this._notificationService, this._analyticsService) {
    _init();
  }

  Future<void> _init() async {
    _isLoadingController.add(true);

    try {
      // Load user data

      // Load theme preference
      final savedTheme = await _loadThemePreference();
      _themeController.add(savedTheme);

      // Load streak data
      await _loadStreakData();

      // Load achievements count
      await _loadAchievementsCount();

      // Initialize notification service
      await _notificationService.init();

      // Schedule daily check-in reminder
      _scheduleDailyReminder();

      // Log app open event
      _analyticsService.logEvent('app_opened');

    } catch (e) {
      _errorController.add('Failed to initialize app: $e');
    } finally {
      _isLoadingController.add(false);
    }
  }

  Future<ThemeMode> _loadThemePreference() async {
    // In a real app, this would load from shared preferences
    return ThemeMode.system;
  }

  Future<void> _loadStreakData() async {
    // Calculate streak based on consecutive days of app usage
    final streak = await _calculateStreak();
    _streakController.add(streak);
  }

  Future<int> _calculateStreak() async {
    // In a real app, this would calculate based on user activity
    return 3; // Placeholder value
  }

  Future<void> _loadAchievementsCount() async {
    //final achievements = _databaseService.getAllAchievements();
    //final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    //_achievementsController.add(unlockedCount);
  }

  void _scheduleDailyReminder() {
    _notificationService.scheduleDailyReminder(
      title: 'Daily Check-in',
      body: 'How are you feeling today? Take a moment to track your mood.',
      time: const TimeOfDay(hour: 20, minute: 0),
    );
  }

  // Theme management
  Future<void> setTheme(ThemeMode theme) async {
    _themeController.add(theme);
    // In a real app, save to shared preferences
  }

  // User management
  Future<void> updateUser(UserModel user) async {
    _isLoadingController.add(true);

    try {
      //await _databaseService.saveUser(user);
      _userController.add(user);
      _analyticsService.logEvent('user_updated');
    } catch (e) {
      _errorController.add('Failed to update user: $e');
    } finally {
      _isLoadingController.add(false);
    }
  }

  // Streak management
  Future<void> incrementStreak() async {
    final newStreak = _streakController.value + 1;
    _streakController.add(newStreak);

    // Check for streak achievements
    if (newStreak == 7) {
      _notificationService.showAchievementNotification(
        title: 'Achievement Unlocked!',
        body: 'You\'ve maintained a 7-day streak! Keep it up!',
      );
      _analyticsService.logEvent('achievement_unlocked', {'type': 'streak_7_days'});
    }
  }

  // Achievement management
  Future<void> refreshAchievements() async {
    await _loadAchievementsCount();
  }

  // Error handling
  void clearError() {
    _errorController.add(null);
  }

  // Cleanup
  void dispose() {
    _themeController.close();
    _userController.close();
    _isLoadingController.close();
    _errorController.close();
    _streakController.close();
    _achievementsController.close();
  }
}

// TODO Implement this library.
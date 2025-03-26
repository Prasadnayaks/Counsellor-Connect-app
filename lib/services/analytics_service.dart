// A simple analytics service to track user behavior
class AnalyticsService {
  // In a real app, this would integrate with Firebase Analytics or similar

  void logEvent(String eventName, [Map<String, dynamic>? parameters]) {
    // Log event to analytics service
    print('Analytics Event: $eventName, Parameters: $parameters');
  }

  void setUserProperty(String name, String value) {
    // Set user property in analytics service
    print('Analytics User Property: $name = $value');
  }

  void logScreenView(String screenName) {
    logEvent('screen_view', {'screen_name': screenName});
  }

  void logLogin(String method) {
    logEvent('login', {'method': method});
  }

  void logSignUp(String method) {
    logEvent('sign_up', {'method': method});
  }

  void logMoodTracked(String mood) {
    logEvent('mood_tracked', {'mood': mood});
  }

  void logJournalEntry() {
    logEvent('journal_entry_created');
  }

  void logCBTExerciseCompleted(String exerciseType, int durationSeconds) {
    logEvent('cbt_exercise_completed', {
      'exercise_type': exerciseType,
      'duration_seconds': durationSeconds,
    });
  }

  void logRelaxationSessionCompleted(String technique, int durationSeconds) {
    logEvent('relaxation_session_completed', {
      'technique': technique,
      'duration_seconds': durationSeconds,
    });
  }

  void logAchievementUnlocked(String achievementId) {
    logEvent('achievement_unlocked', {'achievement_id': achievementId});
  }

  void logAppointmentScheduled() {
    logEvent('appointment_scheduled');
  }

  void logAppointmentCancelled() {
    logEvent('appointment_cancelled');
  }

  void logFeatureUsed(String featureName) {
    logEvent('feature_used', {'feature_name': featureName});
  }

  void logError(String errorType, String errorMessage) {
    logEvent('app_error', {
      'error_type': errorType,
      'error_message': errorMessage,
    });
  }
}


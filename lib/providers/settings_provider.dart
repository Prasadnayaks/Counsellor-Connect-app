import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isLoading = false;
  SharedPreferences? _prefs;
  final String _settingsKey = 'app_settings';
  
  // Default settings
  bool _enableNotifications = true;
  bool _enableSounds = true;
  String _reminderTime = '20:00'; // Default reminder time (8:00 PM)
  String _language = 'en'; // Default language is English
  bool _useBiometrics = false;
  int _dataRetentionDays = 90; // How long to keep data
  bool _syncWithCloud = false;
  Map<String, bool> _featureFlags = {
    'showChallenges': true,
    'enableJournalPrompts': true,
    'showMoodInsights': true,
    'enableRelaxationReminders': true,
  };
  
  // Getters
  bool get isLoading => _isLoading;
  bool get enableNotifications => _enableNotifications;
  bool get enableSounds => _enableSounds;
  String get reminderTime => _reminderTime;
  String get language => _language;
  bool get useBiometrics => _useBiometrics;
  int get dataRetentionDays => _dataRetentionDays;
  bool get syncWithCloud => _syncWithCloud;
  Map<String, bool> get featureFlags => Map.unmodifiable(_featureFlags);

  SettingsProvider() {
    _initPrefs();
  }

  // Initialize shared preferences
  Future<void> _initPrefs() async {
    _isLoading = true;
    notifyListeners();
    
    _prefs = await SharedPreferences.getInstance();
    _loadSettingsFromPrefs();
    
    _isLoading = false;
    notifyListeners();
  }

  // Load settings from shared preferences
  void _loadSettingsFromPrefs() {
    final settingsJson = _prefs?.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> settings = json.decode(settingsJson);
        
        _enableNotifications = settings['enableNotifications'] ?? _enableNotifications;
        _enableSounds = settings['enableSounds'] ?? _enableSounds;
        _reminderTime = settings['reminderTime'] ?? _reminderTime;
        _language = settings['language'] ?? _language;
        _useBiometrics = settings['useBiometrics'] ?? _useBiometrics;
        _dataRetentionDays = settings['dataRetentionDays'] ?? _dataRetentionDays;
        _syncWithCloud = settings['syncWithCloud'] ?? _syncWithCloud;
        
        if (settings['featureFlags'] != null) {
          final Map<String, dynamic> flags = settings['featureFlags'];
          for (var key in _featureFlags.keys) {
            if (flags.containsKey(key)) {
              _featureFlags[key] = flags[key];
            }
          }
        }
      } catch (e) {
        print('Error loading settings: $e');
      }
    }
  }

  // Save settings to shared preferences
  Future<void> _saveSettingsToPrefs() async {
    final Map<String, dynamic> settings = {
      'enableNotifications': _enableNotifications,
      'enableSounds': _enableSounds,
      'reminderTime': _reminderTime,
      'language': _language,
      'useBiometrics': _useBiometrics,
      'dataRetentionDays': _dataRetentionDays,
      'syncWithCloud': _syncWithCloud,
      'featureFlags': _featureFlags,
    };

    final settingsJson = json.encode(settings);
    await _prefs?.setString(_settingsKey, settingsJson);
  }

  // Update notification settings
  Future<void> updateNotificationSettings({required bool enabled}) async {
    _isLoading = true;
    notifyListeners();

    _enableNotifications = enabled;
    await _saveSettingsToPrefs();
    
    _isLoading = false;
    notifyListeners();
  }

  // Update sound settings
  Future<void> updateSoundSettings({required bool enabled}) async {
    _isLoading = true;
    notifyListeners();

    _enableSounds = enabled;
    await _saveSettingsToPrefs();
    
    _isLoading = false;
    notifyListeners();
  }

  // Update reminder time
  Future<void> updateReminderTime({required String time}) async {
    _isLoading = true;
    notifyListeners();

    _reminderTime = time;
    await _saveSettingsToPrefs();
    
    _isLoading = false;
    notifyListeners();
  }

  // Update language
  Future<void> updateLanguage({required String language}) async {
    _isLoading = true;
    notifyListeners();

    _language = language;
    await _saveSettingsToPrefs();
    
    _isLoading = false;
    notifyListeners();
  }

  // Update biometrics setting
  Future<void> updateBiometrics({required bool enabled}) async {
    _isLoading = true;
    notifyListeners();

    _useBiometrics = enabled;
    await _saveSettingsToPrefs();
    
    _isLoading = false;
    notifyListeners();
  }

  // Update data retention period
  Future<void> updateDataRetention({required int days}) async {
    _isLoading = true;
    notifyListeners();

    _dataRetentionDays = days;
    await _saveSettingsToPrefs();
    
    _isLoading = false;
    notifyListeners();
  }

  // Update cloud sync setting
  Future<void> updateCloudSync({required bool enabled}) async {
    _isLoading = true;
    notifyListeners();

    _syncWithCloud = enabled;
    await _saveSettingsToPrefs();
    
    _isLoading = false;
    notifyListeners();
  }

  // Update a feature flag
  Future<void> updateFeatureFlag({required String feature, required bool enabled}) async {
    _isLoading = true;
    notifyListeners();

    if (_featureFlags.containsKey(feature)) {
      _featureFlags[feature] = enabled;
      await _saveSettingsToPrefs();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _isLoading = true;
    notifyListeners();

    _enableNotifications = true;
    _enableSounds = true;
    _reminderTime = '20:00';
    _language = 'en';
    _useBiometrics = false;
    _dataRetentionDays = 90;
    _syncWithCloud = false;
    _featureFlags = {
      'showChallenges': true,
      'enableJournalPrompts': true,
      'showMoodInsights': true,
      'enableRelaxationReminders': true,
    };
    
    await _saveSettingsToPrefs();
    
    _isLoading = false;
    notifyListeners();
  }
} 
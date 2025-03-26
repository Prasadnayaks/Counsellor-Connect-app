import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart'; // Import your UserModel

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  SharedPreferences? _prefs;
  final String _userKey = 'current_user';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _isLoading = true;
    notifyListeners();

    _prefs = await SharedPreferences.getInstance();
    _loadUserFromPrefs();

    _isLoading = false;
    notifyListeners();
  }

  void _loadUserFromPrefs() {
    final userJson = _prefs?.getString(_userKey);
    if (userJson != null) {
      try {
        final userMap = json.decode(userJson);
        _currentUser = UserModel(id: '')
          ..name = userMap['name']
          ..role = userMap['role']
          ..age = userMap['age']
          ..goal = userMap['goal']
          ..selectedChallenges = List<String>.from(userMap['selectedChallenges'] ?? [])
          ..supportStyle = userMap['supportStyle']
          ..supportResponses = Map<String, dynamic>.from(userMap['supportResponses'] ?? {});
      } catch (e) {
        print('Error loading user: $e');
      }
    }
  }

  Future<void> _saveUserToPrefs() async {
    if (_currentUser != null) {
      final userJson = json.encode({
        'name': _currentUser!.name,
        'role': _currentUser!.role,
        'age': _currentUser!.age,
        'goal': _currentUser!.goal,
        'selectedChallenges': _currentUser!.selectedChallenges,
        'supportStyle': _currentUser!.supportStyle,
        'supportResponses': _currentUser!.supportResponses,
      });
      await _prefs?.setString(_userKey, userJson);
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (email == 'user@example.com' && password == 'password') {
      _currentUser = UserModel(id: '')
        ..name = 'Alex'
        ..role = 'User'
        ..age = 25
        ..goal = 'Fitness'
        ..selectedChallenges = ['Challenge1', 'Challenge2']
        ..supportStyle = 'Encouraging'
        ..supportResponses = {'response1': 'Great job!'};

      await _saveUserToPrefs();

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> createAccount(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(id: '')
      ..name = name
      ..role = 'New User'
      ..age = 20
      ..goal = 'Health'
      ..selectedChallenges = []
      ..supportStyle = 'Supportive'
      ..supportResponses = {};

    await _saveUserToPrefs();

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = null;
    await _prefs?.remove(_userKey);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? role, int? age}) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    _currentUser = UserModel(id: '')
      ..name = name ?? _currentUser!.name
      ..role = role ?? _currentUser!.role
      ..age = age ?? _currentUser!.age
      ..goal = _currentUser!.goal
      ..selectedChallenges = _currentUser!.selectedChallenges
      ..supportStyle = _currentUser!.supportStyle
      ..supportResponses = _currentUser!.supportResponses;

    await _saveUserToPrefs();

    _isLoading = false;
    notifyListeners();
  }
}
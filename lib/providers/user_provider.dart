import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  UserModel? _user;
  bool _isLoading = true;

  UserProvider(this._firebaseService) {
    _loadUser();
  }

  UserModel? get user => _user;
  String get userName => _user?.name ?? 'User';
  String? get userRole => _user?.role;
  List<String> get selectedChallenges => _user?.selectedChallenges ?? [];
  String? get supportStyle => _user?.supportStyle;
  Map<String, dynamic> get supportResponses => _user?.supportResponses ?? {};
  bool get isLoading => _isLoading;
  bool get isUserInitialized => _user != null && _user!.role != null;

  // Add methods to handle onboarding status
  bool get isOnboardingCompleted => _user?.onboardingCompleted ?? false;

  Future<void> completeOnboarding() async {
    try {
      await _firebaseService.updateOnboardingStatus(true);
      await _loadUser();
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
    }
  }

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _firebaseService.getUser();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserRole(String role) async {
    try {
      await _firebaseService.updateUserRole(role);
      await _loadUser();
    } catch (e) {
      debugPrint('Error updating user role: $e');
    }
  }

  Future<void> updateUserName(String name) async {
    try {
      await _firebaseService.updateUserName(name);
      await _loadUser();
    } catch (e) {
      debugPrint('Error updating user name: $e');
    }
  }

  Future<void> updateUserDetails({String? name, int? age, String? goal}) async {
    try {
      await _firebaseService.updateUserDetails(
        name: name,
        age: age,
        goal: goal,
      );
      await _loadUser();
    } catch (e) {
      debugPrint('Error updating user details: $e');
    }
  }

  Future<void> updateUserChallenges(List<String> challenges) async {
    try {
      await _firebaseService.updateUserChallenges(challenges);
      await _loadUser();
    } catch (e) {
      debugPrint('Error updating user challenges: $e');
    }
  }

  Future<void> updateUserSupportStyle(String style) async {
    try {
      await _firebaseService.updateUserSupportStyle(style);
      await _loadUser();
    } catch (e) {
      debugPrint('Error updating user support style: $e');
    }
  }

  Future<void> updateUserSupportResponses(Map<String, dynamic> responses) async {
    try {
      await _firebaseService.updateUserSupportResponses(responses);
      await _loadUser();
    } catch (e) {
      debugPrint('Error updating user support responses: $e');
    }
  }

  Future<void> clearUserData() async {
    try {
      await _firebaseService.clearUserData();
      await _loadUser();
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }
}


import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class CounselorProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  List<Map<String, dynamic>> _onlineCounselors = [];
  int _onlineCounselorCount = 0;
  bool _isLoading = true;

  CounselorProvider(this._firebaseService) {
    _loadCounselors();
  }

  List<Map<String, dynamic>> get onlineCounselors => _onlineCounselors;
  int get onlineCounselorCount => _onlineCounselorCount;
  bool get isLoading => _isLoading;

  Future<void> _loadCounselors() async {
    _isLoading = true;
    notifyListeners();

    try {
      _onlineCounselors = await _firebaseService.getOnlineCounselors();
      _onlineCounselorCount = _onlineCounselors.length;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading counselors: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCounselors() async {
    await _loadCounselors();
  }

  Future<void> setUserOnline() async {
    await _firebaseService.setUserOnline();
  }

  Future<void> setUserOffline() async {
    await _firebaseService.setUserOffline();
  }

  Future<UserModel?> getCounselorDetails(String counselorId) async {
    try {
      return await _firebaseService.getUserById(counselorId);
    } catch (e) {
      debugPrint('Error getting counselor details: $e');
      return null;
    }
  }
}


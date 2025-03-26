import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../appointment.dart';
import '../services/firebase_service.dart';
import '../providers/notification_provider.dart';

class AppointmentProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final NotificationProvider? _notificationProvider;
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  AppointmentProvider(
      this._firebaseService, {
        NotificationProvider? notificationProvider,
      }) : _notificationProvider = notificationProvider {
    _loadAppointments();
  }

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;

  Future<void> _loadAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load appointments based on user role
      final user = await _firebaseService.getUser();

      if (user?.role == 'counselor') {
        _appointments = await _firebaseService.getCounselorAppointments();
      } else {
        _appointments = await _firebaseService.getAllAppointments();
      }

      _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAppointment({
    required String title,
    required DateTime dateTime,
    required String counselorId,
    required String counselorName,
    String? notes,
    String? userId,
    String? userName,
  }) async {
    try {
      final appointment = Appointment(
        id: const Uuid().v4(),
        title: title,
        dateTime: dateTime,
        userId: userId ?? _firebaseService.currentUserId,
        counselorId: counselorId,
        counselorName: counselorName,
        notes: notes,
        isCompleted: false,
      );

      await _firebaseService.saveAppointment(appointment);

      // Schedule notification
      if (_notificationProvider != null) {
        _notificationProvider!.scheduleAppointmentReminder(appointment);
      }

      await _loadAppointments();
    } catch (e) {
      debugPrint('Error adding appointment: $e');
    }
  }

  Future<void> updateAppointment({
    required String id,
    required String title,
    required DateTime dateTime,
    required String counselorId,
    required String counselorName,
    String? notes,
    bool? isCompleted,
  }) async {
    try {
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        final appointment = _appointments[index];
        final updatedAppointment = Appointment(
          id: appointment.id,
          title: title,
          dateTime: dateTime,
          userId: appointment.userId,
          counselorId: counselorId,
          counselorName: counselorName,
          notes: notes,
          isCompleted: isCompleted ?? appointment.isCompleted,
        );

        await _firebaseService.saveAppointment(updatedAppointment);

        // Update notification
        if (_notificationProvider != null) {
          _notificationProvider!.cancelAppointmentReminder(appointment.id);
          _notificationProvider!.scheduleAppointmentReminder(updatedAppointment);
        }

        await _loadAppointments();
      }
    } catch (e) {
      debugPrint('Error updating appointment: $e');
    }
  }

  Future<void> deleteAppointment(String id) async {
    try {
      await _firebaseService.deleteAppointment(id);

      // Cancel notification
      if (_notificationProvider != null) {
        _notificationProvider!.cancelAppointmentReminder(id);
      }

      await _loadAppointments();
    } catch (e) {
      debugPrint('Error deleting appointment: $e');
    }
  }

  Future<void> markAppointmentAsCompleted(String id) async {
    try {
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        final appointment = _appointments[index];
        final updatedAppointment = Appointment(
          id: appointment.id,
          title: appointment.title,
          dateTime: appointment.dateTime,
          userId: appointment.userId,
          counselorId: appointment.counselorId,
          counselorName: appointment.counselorName,
          notes: appointment.notes,
          isCompleted: true,
        );

        await _firebaseService.saveAppointment(updatedAppointment);

        // Cancel notification
        if (_notificationProvider != null) {
          _notificationProvider!.cancelAppointmentReminder(id);
        }

        await _loadAppointments();
      }
    } catch (e) {
      debugPrint('Error marking appointment as completed: $e');
    }
  }

  List<Appointment> getUpcomingAppointments() {
    final now = DateTime.now();
    return _appointments
        .where((a) => a.dateTime.isAfter(now) && !a.isCompleted)
        .toList();
  }

  List<Appointment> getPastAppointments() {
    final now = DateTime.now();
    return _appointments
        .where((a) => a.dateTime.isBefore(now) || a.isCompleted)
        .toList();
  }

  // Refresh appointments
  Future<void> refreshAppointments() async {
    await _loadAppointments();
  }
}


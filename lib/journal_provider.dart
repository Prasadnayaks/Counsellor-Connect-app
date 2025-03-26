import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wysa_app/providers/achievement_provider.dart';
import 'journal_entry.dart';
import '../services/firebase_service.dart';

class JournalProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  List<JournalEntry> _journalEntries = [];
  bool _isLoading = true;

  JournalProvider(this._firebaseService, {required AchievementProvider achievementProvider}) {
    _loadJournalEntries();
  }

  List<JournalEntry> get journalEntries => _journalEntries;
  bool get isLoading => _isLoading;

  Future<void> _loadJournalEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _journalEntries = await _firebaseService.getAllJournalEntries();
      _journalEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading journal entries: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addJournalEntry(String title, String content, {List<String>? tags}) async {
    try {
      final entry = JournalEntry(
        id: const Uuid().v4(),
        title: title,
        content: content,
        timestamp: DateTime.now(),
        tags: tags,
      );

      await _firebaseService.saveJournalEntry(entry);
      await _loadJournalEntries();
    } catch (e) {
      debugPrint('Error adding journal entry: $e');
    }
  }

  Future<void> deleteJournalEntry(String id) async {
    try {
      await _firebaseService.deleteJournalEntry(id);
      await _loadJournalEntries();
    } catch (e) {
      debugPrint('Error deleting journal entry: $e');
    }
  }

  List<JournalEntry> getJournalEntriesForDate(DateTime date) {
    return _journalEntries.where((entry) {
      return entry.timestamp.year == date.year &&
          entry.timestamp.month == date.month &&
          entry.timestamp.day == date.day;
    }).toList();
  }

  List<JournalEntry> getJournalEntriesWithTag(String tag) {
    return _journalEntries.where((entry) {
      return entry.tags != null && entry.tags!.contains(tag);
    }).toList();
  }

  List<String> getAllTags() {
    final Set<String> tags = {};

    for (var entry in _journalEntries) {
      if (entry.tags != null) {
        tags.addAll(entry.tags!);
      }
    }

    return tags.toList();
  }
}


import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// A service for logging events and errors in the app
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal();

  final bool _enableFileLogging = true;
  final int _maxLogFiles = 5;
  final int _maxLogSize = 5 * 1024 * 1024; // 5 MB

  // Log levels
  static const int _levelInfo = 0;
  static const int _levelWarning = 1;
  static const int _levelError = 2;

  // Format the current time for logs
  String _getFormattedTime() {
    return DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
  }

  // Log an info message
  void info(String message) {
    _log(_levelInfo, message);
  }

  // Log a warning message
  void warning(String message) {
    _log(_levelWarning, message);
  }

  // Log an error message
  void error(String message) {
    _log(_levelError, message);
  }

  // Log a message with the specified level
  void _log(int level, String message) {
    final time = _getFormattedTime();
    String levelString;

    switch (level) {
      case _levelInfo:
        levelString = 'INFO';
        break;
      case _levelWarning:
        levelString = 'WARNING';
        break;
      case _levelError:
        levelString = 'ERROR';
        break;
      default:
        levelString = 'UNKNOWN';
    }

    final logMessage = '[$time] $levelString: $message';

    // Print to console in debug mode
    if (kDebugMode) {
      print(logMessage);
    }

    // Write to file if enabled
    if (_enableFileLogging) {
      _writeToFile(logMessage);
    }
  }

  // Write a log message to file
  Future<void> _writeToFile(String message) async {
    try {
      final directory = await _getLogDirectory();
      final file = File('${directory.path}/app_log_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.txt');

      // Create file if it doesn't exist
      if (!await file.exists()) {
        await file.create(recursive: true);

        // Clean up old log files
        _cleanupOldLogs(directory);
      }

      // Check file size and rotate if needed
      if (await file.exists()) {
        final fileSize = await file.length();
        if (fileSize > _maxLogSize) {
          await _rotateLogFile(file);
        }
      }

      // Append message to file
      await file.writeAsString('$message\n', mode: FileMode.append);
    } catch (e) {
      if (kDebugMode) {
        print('Error writing to log file: $e');
      }
    }
  }

  // Get the directory for storing log files
  Future<Directory> _getLogDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDir.path}/logs');

    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    return logDir;
  }

  // Rotate log file when it gets too large
  Future<void> _rotateLogFile(File file) async {
    final path = file.path;
    final timestamp = DateFormat('HHmmss').format(DateTime.now());
    final newPath = '$path.$timestamp';

    await file.rename(newPath);
  }

  // Clean up old log files
  Future<void> _cleanupOldLogs(Directory directory) async {
    try {
      final files = await directory.list().toList();

      // Sort files by modification time (oldest first)
      files.sort((a, b) {
        return a.statSync().modified.compareTo(b.statSync().modified);
      });

      // Delete oldest files if we have too many
      if (files.length > _maxLogFiles) {
        for (var i = 0; i < files.length - _maxLogFiles; i++) {
          await files[i].delete();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up log files: $e');
      }
    }
  }

  // Get all logs as a string
  Future<String> getAllLogs() async {
    try {
      final directory = await _getLogDirectory();
      final files = await directory.list().toList();

      // Sort files by modification time (newest first)
      files.sort((a, b) {
        return b.statSync().modified.compareTo(a.statSync().modified);
      });

      // Combine logs from all files
      final buffer = StringBuffer();
      for (var file in files) {
        if (file is File && file.path.endsWith('.txt')) {
          final content = await File(file.path).readAsString();
          buffer.write(content);
        }
      }

      return buffer.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all logs: $e');
      }
      return 'Error retrieving logs: $e';
    }
  }
}


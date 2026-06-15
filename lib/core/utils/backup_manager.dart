import 'dart:async';
import 'backup_service.dart';

/// A debounced backup manager that coalesces multiple backup requests
/// into a single export operation after a period of inactivity.
///
/// Instead of exporting the entire database on every single write,
/// this schedules a backup after [debounceDuration] of inactivity.
/// If another write occurs before the timer fires, the timer resets.
class BackupManager {
  static final BackupManager _instance = BackupManager._internal();
  factory BackupManager() => _instance;
  BackupManager._internal();

  static BackupManager get instance => _instance;

  Timer? _debounceTimer;
  final Duration debounceDuration = const Duration(seconds: 10);

  /// Schedule a backup. If called multiple times within [debounceDuration],
  /// only the last call triggers the actual export.
  void scheduleBackup() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () async {
      await BackupService.exportToExcel();
    });
  }

  /// Force an immediate backup (e.g., on app pause/lifecycle change).
  Future<void> flushNow() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    await BackupService.exportToExcel();
  }

  /// Cancel any pending backup (e.g., on dispose).
  void cancel() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}

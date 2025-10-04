import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/habit.dart';

class BackupService {
  static const String _habitsBoxName = 'habits';

  // Export data to JSON
  static Future<bool> exportData() async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            return false;
          }
        }
      }

      // Get habits box
      final habitsBox = Hive.box<Habit>(_habitsBoxName);

      // Convert habits to JSON-serializable format
      final habitsData = <String, dynamic>{};
      for (var key in habitsBox.keys) {
        final habit = habitsBox.get(key);
        if (habit != null) {
          habitsData[key.toString()] = {
            'id': habit.id,
            'name': habit.name,
            'icon': habit.icon,
            'frequency': {
              'type': habit.frequency.type,
              'days': habit.frequency.days,
            },
            'reminderTime': habit.reminderTime,
            'createdAt': habit.createdAt.toIso8601String(),
            'subtype': habit.subtype,
          };
        }
      }

      // Create backup object
      final backupData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'appName': 'Pocket Habits',
        'habits': habitsData,
      };

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // Get downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) return false;

      // Create file with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/pocket_habits_backup_$timestamp.json');

      // Write to file
      await file.writeAsString(jsonString);

      return true;
    } catch (e) {
      print('Export error: $e');
      return false;
    }
  }

  // Import data from JSON
  static Future<bool> importData() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

        // Validate backup format
        if (!backupData.containsKey('habits') || !backupData.containsKey('version')) {
          return false;
        }

        // Get habits box
        final habitsBox = Hive.box<Habit>(_habitsBoxName);

        // Clear existing data (optional - you might want to ask user)
        await habitsBox.clear();

        // Import habits
        final habitsData = backupData['habits'] as Map<String, dynamic>;
        for (var entry in habitsData.entries) {
          try {
            final habitData = entry.value as Map<String, dynamic>;

            // Recreate HabitFrequency
            final frequencyData = habitData['frequency'] as Map<String, dynamic>;
            final frequency = HabitFrequency(
              type: frequencyData['type'] as String,
              days: List<int>.from(frequencyData['days']),
            );

            // Parse createdAt date
            DateTime createdAt;
            if (habitData['createdAt'] != null) {
              createdAt = DateTime.parse(habitData['createdAt'] as String);
            } else {
              // Fallback to current time if createdAt is missing
              createdAt = DateTime.now();
            }

            // Recreate Habit
            final habit = Habit(
              id: habitData['id'] as String,
              name: habitData['name'] as String,
              icon: habitData['icon'] as String,
              frequency: frequency,
              reminderTime: habitData['reminderTime'] as String?,
              createdAt: createdAt,
              subtype: habitData['subtype'] as String?,
            );

            // Save to box
            await habitsBox.put(entry.key, habit);
          } catch (e) {
            print('Error importing habit ${entry.key}: $e');
            // Continue with other habits even if one fails
            continue;
          }
        }

        return true;
      }
      return false;
    } catch (e) {
      print('Import error: $e');
      return false;
    }
  }

  // Get backup file info without importing
  static Future<Map<String, dynamic>?> getBackupInfo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

        if (backupData.containsKey('habits') && backupData.containsKey('version')) {
          final habitsData = backupData['habits'] as Map<String, dynamic>;
          return {
            'version': backupData['version'],
            'exportDate': backupData['exportDate'],
            'habitsCount': habitsData.length,
            'appName': backupData['appName'] ?? 'Unknown',
          };
        }
      }
      return null;
    } catch (e) {
      print('Error reading backup info: $e');
      return null;
    }
  }
}

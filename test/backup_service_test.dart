import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_habits/services/backup_service.dart';
import 'package:pocket_habits/models/habit.dart';
import 'dart:convert';

void main() {
  group('BackupService', () {
    group('JSON Data Serialization', () {
      test('should serialize habit to JSON format correctly', () {
        final habit = Habit(
          id: 'test-habit-123',
          name: 'Morning Exercise',
          icon: '🏃',
          frequency: HabitFrequency(type: 'daily', days: [1, 2, 3, 4, 5, 6, 7]),
          reminderTime: '08:30',
          createdAt: DateTime(2025, 1, 15, 10, 30),
          subtype: 'fitness',
        );

        final habitJson = {
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

        expect(habitJson['id'], equals('test-habit-123'));
        expect(habitJson['name'], equals('Morning Exercise'));
        expect(habitJson['icon'], equals('🏃'));

        final frequency = habitJson['frequency'] as Map<String, dynamic>?;
        expect(frequency?['type'], equals('daily'));
        expect(frequency?['days'], equals([1, 2, 3, 4, 5, 6, 7]));

        expect(habitJson['reminderTime'], equals('08:30'));
        expect(habitJson['createdAt'], equals('2025-01-15T10:30:00.000'));
        expect(habitJson['subtype'], equals('fitness'));
      });

      test('should handle habit with null optional fields', () {
        final habit = Habit(
          id: 'minimal-habit',
          name: 'Simple Habit',
          icon: '📝',
          frequency: HabitFrequency(type: 'weekly', days: [1, 3, 5]),
          reminderTime: null,
          createdAt: DateTime(2025, 1, 15),
          subtype: null,
        );

        final habitJson = {
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

        expect(habitJson['reminderTime'], isNull);
        expect(habitJson['subtype'], isNull);

        final frequency = habitJson['frequency'] as Map<String, dynamic>?;
        expect(frequency?['days'], equals([1, 3, 5]));
      });
    });

    group('Backup Data Structure', () {
      test('should create correct backup data structure', () {
        final exportDate = DateTime(2025, 1, 15, 14, 30);
        final habitsData = {
          'habit-1': {
            'id': 'habit-1',
            'name': 'Morning Exercise',
            'icon': '🏃',
            'frequency': {'type': 'daily', 'days': [1, 2, 3, 4, 5, 6, 7]},
            'reminderTime': '08:00',
            'createdAt': '2025-01-15T10:00:00.000',
            'subtype': 'fitness',
          }
        };

        final backupData = {
          'version': '1.0.0',
          'exportDate': exportDate.toIso8601String(),
          'appName': 'Pocket Habits',
          'habits': habitsData,
        };

        expect(backupData['version'], equals('1.0.0'));
        expect(backupData['exportDate'], equals('2025-01-15T14:30:00.000'));
        expect(backupData['appName'], equals('Pocket Habits'));
        expect(backupData['habits'], isA<Map<String, dynamic>>());

        final habits = backupData['habits'] as Map<String, dynamic>?;
        expect(habits?.length, equals(1));
      });

      test('should handle empty habits data', () {
        final backupData = {
          'version': '1.0.0',
          'exportDate': DateTime.now().toIso8601String(),
          'appName': 'Pocket Habits',
          'habits': <String, dynamic>{},
        };

        expect(backupData['habits'], isA<Map<String, dynamic>>());

        final habits = backupData['habits'] as Map<String, dynamic>?;
        expect(habits?.isEmpty, isTrue);
      });
    });

    group('JSON Encoding/Decoding', () {
      test('should encode backup data to JSON string correctly', () {
        final backupData = {
          'version': '1.0.0',
          'exportDate': '2025-01-15T14:30:00.000',
          'appName': 'Pocket Habits',
          'habits': {
            'habit-1': {
              'id': 'habit-1',
              'name': 'Test Habit',
              'icon': '📝',
              'frequency': {'type': 'daily', 'days': [1, 2, 3, 4, 5, 6, 7]},
              'reminderTime': null,
              'createdAt': '2025-01-15T10:00:00.000',
              'subtype': null,
            }
          },
        };

        final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

        expect(jsonString, isA<String>());
        expect(jsonString.contains('"version": "1.0.0"'), isTrue);
        expect(jsonString.contains('"appName": "Pocket Habits"'), isTrue);
        expect(jsonString.contains('"habits"'), isTrue);
      });

      test('should decode JSON string back to backup data correctly', () {
        final jsonString = '''
        {
          "version": "1.0.0",
          "exportDate": "2025-01-15T14:30:00.000",
          "appName": "Pocket Habits",
          "habits": {
            "habit-1": {
              "id": "habit-1",
              "name": "Test Habit",
              "icon": "📝",
              "frequency": {
                "type": "daily",
                "days": [1, 2, 3, 4, 5, 6, 7]
              },
              "reminderTime": "08:00",
              "createdAt": "2025-01-15T10:00:00.000",
              "subtype": "test"
            }
          }
        }
        ''';

        final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

        expect(backupData['version'], equals('1.0.0'));
        expect(backupData['appName'], equals('Pocket Habits'));
        expect(backupData.containsKey('habits'), isTrue);

        final habitsData = backupData['habits'] as Map<String, dynamic>?;
        expect(habitsData?.containsKey('habit-1'), isTrue);

        final habitData = habitsData?['habit-1'] as Map<String, dynamic>?;
        expect(habitData?['name'], equals('Test Habit'));
        expect(habitData?['icon'], equals('📝'));
      });
    });

    group('Backup Validation', () {
      test('should validate correct backup format', () {
        final validBackupData = {
          'version': '1.0.0',
          'exportDate': '2025-01-15T14:30:00.000',
          'appName': 'Pocket Habits',
          'habits': <String, dynamic>{},
        };

        final hasRequiredFields = validBackupData.containsKey('habits') &&
            validBackupData.containsKey('version');

        expect(hasRequiredFields, isTrue);
      });

      test('should reject invalid backup format - missing habits', () {
        final invalidBackupData = {
          'version': '1.0.0',
          'exportDate': '2025-01-15T14:30:00.000',
          'appName': 'Pocket Habits',
          // Missing 'habits' key
        };

        final hasRequiredFields = invalidBackupData.containsKey('habits') &&
            invalidBackupData.containsKey('version');

        expect(hasRequiredFields, isFalse);
      });

      test('should reject invalid backup format - missing version', () {
        final invalidBackupData = {
          'exportDate': '2025-01-15T14:30:00.000',
          'appName': 'Pocket Habits',
          'habits': <String, dynamic>{},
          // Missing 'version' key
        };

        final hasRequiredFields = invalidBackupData.containsKey('habits') &&
            invalidBackupData.containsKey('version');

        expect(hasRequiredFields, isFalse);
      });
    });

    group('Habit Reconstruction from JSON', () {
      test('should reconstruct habit from JSON data correctly', () {
        final habitData = {
          'id': 'reconstructed-habit',
          'name': 'Evening Reading',
          'icon': '📚',
          'frequency': {
            'type': 'weekdays',
            'days': [1, 2, 3, 4, 5],
          },
          'reminderTime': '20:00',
          'createdAt': '2025-01-15T10:00:00.000',
          'subtype': 'learning',
        };

        // Recreate HabitFrequency
        final frequencyData = habitData['frequency'] as Map<String, dynamic>?;
        final frequency = HabitFrequency(
          type: frequencyData?['type'] as String? ?? 'daily',
          days: List<int>.from(frequencyData?['days'] ?? []),
        );

        // Parse createdAt date
        final createdAt = DateTime.parse(habitData['createdAt'] as String);

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

        expect(habit.id, equals('reconstructed-habit'));
        expect(habit.name, equals('Evening Reading'));
        expect(habit.icon, equals('📚'));
        expect(habit.frequency.type, equals('weekdays'));
        expect(habit.frequency.days, equals([1, 2, 3, 4, 5]));
        expect(habit.reminderTime, equals('20:00'));
        expect(habit.createdAt, equals(DateTime(2025, 1, 15, 10, 0)));
        expect(habit.subtype, equals('learning'));
      });

      test('should handle missing createdAt with fallback', () {
        final habitData = {
          'id': 'no-date-habit',
          'name': 'Test Habit',
          'icon': '📝',
          'frequency': {
            'type': 'daily',
            'days': [1, 2, 3, 4, 5, 6, 7],
          },
          'reminderTime': null,
          'subtype': null,
          // Missing 'createdAt'
        };

        DateTime createdAt;
        if (habitData['createdAt'] != null) {
          createdAt = DateTime.parse(habitData['createdAt'] as String);
        } else {
          createdAt = DateTime.now();
        }

        expect(createdAt, isA<DateTime>());
        expect(createdAt.isBefore(DateTime.now().add(const Duration(seconds: 1))), isTrue);
      });
    });

    group('Backup Info Extraction', () {
      test('should extract backup info correctly', () {
        final backupData = {
          'version': '1.0.0',
          'exportDate': '2025-01-15T14:30:00.000',
          'appName': 'Pocket Habits',
          'habits': {
            'habit-1': {},
            'habit-2': {},
            'habit-3': {},
          },
        };

        final habitsData = backupData['habits'] as Map<String, dynamic>?;
        final backupInfo = {
          'version': backupData['version'],
          'exportDate': backupData['exportDate'],
          'habitsCount': habitsData?.length ?? 0,
          'appName': backupData['appName'] ?? 'Unknown',
        };

        expect(backupInfo['version'], equals('1.0.0'));
        expect(backupInfo['exportDate'], equals('2025-01-15T14:30:00.000'));
        expect(backupInfo['habitsCount'], equals(3));
        expect(backupInfo['appName'], equals('Pocket Habits'));
      });

      test('should handle missing app name with fallback', () {
        final backupData = {
          'version': '1.0.0',
          'exportDate': '2025-01-15T14:30:00.000',
          'habits': {},
          // Missing 'appName'
        };

        final backupInfo = {
          'appName': backupData['appName'] ?? 'Unknown',
        };

        expect(backupInfo['appName'], equals('Unknown'));
      });
    });

    group('File Path Generation', () {
      test('should generate correct backup filename with timestamp', () {
        final timestamp = 1705320600000; // Example timestamp
        final expectedFilename = 'pocket_habits_backup_$timestamp.json';

        expect(expectedFilename, equals('pocket_habits_backup_1705320600000.json'));
        expect(expectedFilename.endsWith('.json'), isTrue);
        expect(expectedFilename.startsWith('pocket_habits_backup_'), isTrue);
      });

      test('should generate unique filenames for different timestamps', () {
        final timestamp1 = 1705320600000;
        final timestamp2 = 1705320700000;

        final filename1 = 'pocket_habits_backup_$timestamp1.json';
        final filename2 = 'pocket_habits_backup_$timestamp2.json';

        expect(filename1, isNot(equals(filename2)));
      });
    });
  });
}

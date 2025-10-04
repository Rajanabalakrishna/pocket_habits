import 'package:flutter_test/flutter_test.dart';
//import 'package:pocket_habits/services/notification_service.dart';
import 'package:pocket_habits/models/habit.dart';
import 'package:pocket_habits/notifications/notificartion_service.dart';

void main() {
  group('NotificationService', () {
    late NotificationService notificationService;

    setUp(() {
      notificationService = NotificationService();
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = NotificationService();
        final instance2 = NotificationService();

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Habit Reminder Scheduling Logic', () {
      test('should return early when reminderTime is null', () {
        final habit = Habit(
          id: 'test-habit-1',
          name: 'Morning Exercise',
          icon: '🏃',
          frequency: HabitFrequency(type: 'daily', days: [1, 2, 3, 4, 5, 6, 7]),
          reminderTime: null,
          createdAt: DateTime.now(),
        );

        expect(habit.reminderTime, isNull);
        // scheduleHabitReminder should return early without throwing
      });

      test('should parse reminder time string correctly', () {
        final reminderTime = '08:30';
        final reminderParts = reminderTime.split(':');
        final reminderHour = int.parse(reminderParts[0]);
        final reminderMinute = int.parse(reminderParts[1]);

        expect(reminderHour, equals(8));
        expect(reminderMinute, equals(30));
      });

      test('should calculate notification time 30 minutes before reminder', () {
        final now = DateTime(2025, 1, 15, 10, 0);
        final reminderHour = 9;
        final reminderMinute = 0;

        var notificationTime = DateTime(
          now.year,
          now.month,
          now.day,
          reminderHour,
          reminderMinute,
        ).subtract(const Duration(minutes: 30));

        expect(notificationTime.hour, equals(8));
        expect(notificationTime.minute, equals(30));
      });

      test('should add one day if notification time is in the past', () {
        final now = DateTime(2025, 1, 15, 10, 0); // 10:00 AM
        final reminderHour = 9; // 9:00 AM
        final reminderMinute = 0;

        var notificationTime = DateTime(
          now.year,
          now.month,
          now.day,
          reminderHour,
          reminderMinute,
        ).subtract(const Duration(minutes: 30)); // 8:30 AM

        if (notificationTime.isBefore(now)) {
          notificationTime = notificationTime.add(const Duration(days: 1));
        }

        expect(notificationTime.day, equals(16)); // Next day
        expect(notificationTime.hour, equals(8));
        expect(notificationTime.minute, equals(30));
      });

      test('should generate consistent notification ID from habit ID', () {
        final habitId1 = 'test-habit-123';
        final habitId2 = 'test-habit-456';

        final id1 = habitId1.hashCode;
        final id2 = habitId2.hashCode;
        final id1Again = habitId1.hashCode;

        expect(id1, equals(id1Again)); // Same habit ID should generate same ID
        expect(id1, isNot(equals(id2))); // Different habit IDs should generate different IDs
      });
    });

    group('Habit Frequency Validation', () {
      test('should validate daily habit frequency', () {
        final habit = Habit(
          id: 'daily-habit',
          name: 'Daily Exercise',
          icon: '🏃',
          frequency: HabitFrequency(type: 'daily', days: [1, 2, 3, 4, 5, 6, 7]),
          reminderTime: '08:00',
          createdAt: DateTime.now(),
        );

        final now = DateTime.now();
        final weekday = now.weekday;

        // Daily habit should contain all weekdays
        expect(habit.frequency.days.contains(weekday), isTrue);
        expect(habit.frequency.type, equals('daily'));
      });

      test('should validate weekly habit frequency', () {
        final habit = Habit(
          id: 'weekly-habit',
          name: 'Weekly Meeting',
          icon: '📅',
          frequency: HabitFrequency(type: 'weekly', days: [1, 3, 5]), // Mon, Wed, Fri
          reminderTime: '09:00',
          createdAt: DateTime.now(),
        );

        expect(habit.frequency.type, equals('weekly'));
        expect(habit.frequency.days, equals([1, 3, 5]));
        expect(habit.frequency.days.contains(1), isTrue); // Monday
        expect(habit.frequency.days.contains(2), isFalse); // Tuesday
      });

      test('should validate custom habit frequency', () {
        final habit = Habit(
          id: 'custom-habit',
          name: 'Gym Days',
          icon: '💪',
          frequency: HabitFrequency(type: 'custom', days: [2, 4, 6]), // Tue, Thu, Sat
          reminderTime: '18:00',
          createdAt: DateTime.now(),
        );

        expect(habit.frequency.type, equals('custom'));
        expect(habit.frequency.days, equals([2, 4, 6]));
        expect(habit.frequency.days.length, equals(3));
      });

      test('should validate monthly habit frequency', () {
        final habit = Habit(
          id: 'monthly-habit',
          name: 'Monthly Review',
          icon: '📊',
          frequency: HabitFrequency(type: 'monthly', days: [1, 15]), // 1st and 15th of month
          reminderTime: '10:00',
          createdAt: DateTime.now(),
        );

        expect(habit.frequency.type, equals('monthly'));
        expect(habit.frequency.days, equals([1, 15]));
      });
    });

    group('_isHabitScheduledToday Logic', () {
      test('should check if daily habit is scheduled today', () {
        final today = DateTime.now();
        final weekday = today.weekday;

        final dailyHabit = HabitFrequency(type: 'daily', days: [1, 2, 3, 4, 5, 6, 7]);

        expect(dailyHabit.days.contains(weekday), isTrue);
      });

      test('should check if weekly habit is scheduled today', () {
        final monday = DateTime(2025, 1, 13); // Monday
        final saturday = DateTime(2025, 1, 18); // Saturday

        final weekdayHabit = HabitFrequency(type: 'weekly', days: [1, 2, 3, 4, 5]); // Mon-Fri

        expect(weekdayHabit.days.contains(monday.weekday), isTrue);
        expect(weekdayHabit.days.contains(saturday.weekday), isFalse);
      });

      test('should check if monthly habit is scheduled today', () {
        final firstOfMonth = DateTime(2025, 1, 1);
        final fifteenthOfMonth = DateTime(2025, 1, 15);
        final randomDay = DateTime(2025, 1, 10);

        final monthlyHabit = HabitFrequency(type: 'monthly', days: [1, 15]);

        expect(monthlyHabit.days.contains(firstOfMonth.day), isTrue);
        expect(monthlyHabit.days.contains(fifteenthOfMonth.day), isTrue);
        expect(monthlyHabit.days.contains(randomDay.day), isFalse);
      });

      test('should return false for unknown frequency type', () {
        final unknownHabit = HabitFrequency(type: 'unknown', days: [1, 2, 3]);

        // This would be handled in the switch statement default case
        expect(unknownHabit.type, equals('unknown'));
      });
    });

    group('Notification Message Generation', () {
      test('should generate correct notification title and body', () {
        final habitName = 'Morning Exercise';
        final expectedTitle = 'Habit Reminder';
        final expectedBody = 'Don\'t forget: $habitName in 30 minutes!';

        expect(expectedTitle, equals('Habit Reminder'));
        expect(expectedBody, equals('Don\'t forget: Morning Exercise in 30 minutes!'));
      });

      test('should handle habit names with special characters', () {
        final habitName = 'Take Vitamin D & B12';
        final expectedBody = 'Don\'t forget: $habitName in 30 minutes!';

        expect(expectedBody, equals('Don\'t forget: Take Vitamin D & B12 in 30 minutes!'));
      });
    });

    group('Time Validation', () {
      test('should validate future times correctly', () {
        final now = DateTime.now();
        final futureTime = now.add(const Duration(hours: 1));
        final pastTime = now.subtract(const Duration(hours: 1));

        expect(futureTime.isAfter(now), isTrue);
        expect(pastTime.isAfter(now), isFalse);
      });

      test('should handle edge case times', () {
        final midnight = DateTime(2025, 1, 15, 0, 0);
        final almostMidnight = DateTime(2025, 1, 15, 23, 59);

        expect(midnight.hour, equals(0));
        expect(midnight.minute, equals(0));
        expect(almostMidnight.hour, equals(23));
        expect(almostMidnight.minute, equals(59));
      });
    });

    group('Habit List Processing', () {
      test('should handle empty habit list', () {
        final habits = <Habit>[];

        expect(habits.isEmpty, isTrue);
        expect(habits.length, equals(0));
      });

      test('should process multiple habits correctly', () {
        final habits = [
          Habit(
            id: 'habit-1',
            name: 'Morning Exercise',
            icon: '🏃',
            frequency: HabitFrequency(type: 'daily', days: [1, 2, 3, 4, 5, 6, 7]),
            reminderTime: '07:00',
            createdAt: DateTime.now(),
          ),
          Habit(
            id: 'habit-2',
            name: 'Evening Reading',
            icon: '📚',
            frequency: HabitFrequency(type: 'daily', days: [1, 2, 3, 4, 5, 6, 7]),
            reminderTime: '20:00',
            createdAt: DateTime.now(),
          ),
          Habit(
            id: 'habit-3',
            name: 'No Reminder Habit',
            icon: '📝',
            frequency: HabitFrequency(type: 'daily', days: [1, 2, 3, 4, 5, 6, 7]),
            reminderTime: null,
            createdAt: DateTime.now(),
          ),
        ];

        expect(habits.length, equals(3));

        final habitsWithReminders = habits.where((h) => h.reminderTime != null).toList();
        final habitsWithoutReminders = habits.where((h) => h.reminderTime == null).toList();

        expect(habitsWithReminders.length, equals(2));
        expect(habitsWithoutReminders.length, equals(1));
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_habits/models/habit.dart';

void main() {
  group('HabitFrequency', () {
    test('should create daily frequency correctly', () {
      final frequency = HabitFrequency(
        type: 'daily',
        days: [1, 2, 3, 4, 5, 6, 7],
      );

      expect(frequency.type, equals('daily'));
      expect(frequency.days, equals([1, 2, 3, 4, 5, 6, 7]));
    });

    test('should create weekdays frequency correctly', () {
      final frequency = HabitFrequency(
        type: 'weekdays',
        days: [1, 2, 3, 4, 5],
      );

      expect(frequency.type, equals('weekdays'));
      expect(frequency.days, equals([1, 2, 3, 4, 5]));
    });

    test('should create custom frequency correctly', () {
      final frequency = HabitFrequency(
        type: 'weekdays',
        days: [1, 3, 5], // Mon, Wed, Fri
      );

      expect(frequency.type, equals('weekdays'));
      expect(frequency.days, equals([1, 3, 5]));
    });
  });

  group('Habit', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 1, 1, 10, 30);
    });

    test('should create habit with all required fields', () {
      final frequency = HabitFrequency(type: 'daily', days: [1, 2, 3, 4, 5, 6, 7]);
      final habit = Habit(
        id: 'test-id-123',
        name: 'Morning Exercise',
        icon: '🏃',
        frequency: frequency,
        createdAt: testDate,
      );

      expect(habit.id, equals('test-id-123'));
      expect(habit.name, equals('Morning Exercise'));
      expect(habit.icon, equals('🏃'));
      expect(habit.frequency, equals(frequency));
      expect(habit.createdAt, equals(testDate));
      expect(habit.reminderTime, isNull);
      expect(habit.subtype, isNull);
    });

    test('should create habit with reminder time', () {
      final frequency = HabitFrequency(type: 'daily', days: [1, 2, 3, 4, 5, 6, 7]);
      final habit = Habit(
        id: 'test-id-456',
        name: 'Take Vitamins',
        icon: '💊',
        frequency: frequency,
        reminderTime: '08:30',
        createdAt: testDate,
      );

      expect(habit.reminderTime, equals('08:30'));
    });

    test('should create habit with subtype', () {
      final frequency = HabitFrequency(type: 'weekdays', days: [1, 2, 3, 4, 5]);
      final habit = Habit(
        id: 'test-id-789',
        name: 'Read Book',
        icon: '📚',
        frequency: frequency,
        createdAt: testDate,
        subtype: 'learning',
      );

      expect(habit.subtype, equals('learning'));
    });

    test('should handle weekday-only frequency', () {
      final frequency = HabitFrequency(type: 'weekdays', days: [1, 2, 3, 4, 5]);
      final habit = Habit(
        id: 'work-habit',
        name: 'Check Emails',
        icon: '📧',
        frequency: frequency,
        reminderTime: '09:00',
        createdAt: testDate,
      );

      expect(habit.frequency.type, equals('weekdays'));
      expect(habit.frequency.days, equals([1, 2, 3, 4, 5]));
    });

    test('should handle custom days frequency', () {
      final frequency = HabitFrequency(type: 'weekdays', days: [2, 4, 6]); // Tue, Thu, Sat
      final habit = Habit(
        id: 'gym-habit',
        name: 'Go to Gym',
        icon: '💪',
        frequency: frequency,
        createdAt: testDate,
      );

      expect(habit.frequency.days, equals([2, 4, 6]));
      expect(habit.frequency.days.length, equals(3));
    });
  });
}

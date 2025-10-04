import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_habits/models/completion_log.dart';

void main() {
  group('CompletionLog', () {
    late DateTime testDate;
    late DateTime todayDate;
    late DateTime yesterdayDate;

    setUp(() {
      testDate = DateTime(2025, 1, 15, 10, 30);
      todayDate = DateTime.now();
      yesterdayDate = DateTime.now().subtract(const Duration(days: 1));
    });

    test('should create completion log with completed status', () {
      final log = CompletionLog(
        habitId: 'habit-123',
        date: testDate,
        isCompleted: true,
      );

      expect(log.habitId, equals('habit-123'));
      expect(log.date, equals(testDate));
      expect(log.isCompleted, isTrue);
    });

    test('should create completion log with incomplete status', () {
      final log = CompletionLog(
        habitId: 'habit-456',
        date: testDate,
        isCompleted: false,
      );

      expect(log.habitId, equals('habit-456'));
      expect(log.date, equals(testDate));
      expect(log.isCompleted, isFalse);
    });

    test('should handle today\'s date correctly', () {
      final log = CompletionLog(
        habitId: 'daily-habit',
        date: todayDate,
        isCompleted: true,
      );

      expect(log.date.day, equals(todayDate.day));
      expect(log.date.month, equals(todayDate.month));
      expect(log.date.year, equals(todayDate.year));
    });

    test('should handle yesterday\'s date correctly', () {
      final log = CompletionLog(
        habitId: 'streak-habit',
        date: yesterdayDate,
        isCompleted: true,
      );

      expect(log.date.day, equals(yesterdayDate.day));
      expect(log.date.month, equals(yesterdayDate.month));
      expect(log.date.year, equals(yesterdayDate.year));
    });

    test('should handle different habit IDs', () {
      final log1 = CompletionLog(
        habitId: 'exercise',
        date: testDate,
        isCompleted: true,
      );

      final log2 = CompletionLog(
        habitId: 'reading',
        date: testDate,
        isCompleted: false,
      );

      expect(log1.habitId, equals('exercise'));
      expect(log2.habitId, equals('reading'));
      expect(log1.habitId, isNot(equals(log2.habitId)));
    });

    test('should handle date with specific time', () {
      final specificTime = DateTime(2025, 1, 15, 14, 45, 30);
      final log = CompletionLog(
        habitId: 'timed-habit',
        date: specificTime,
        isCompleted: true,
      );

      expect(log.date.hour, equals(14));
      expect(log.date.minute, equals(45));
      expect(log.date.second, equals(30));
    });

    test('should handle date-only scenarios (midnight)', () {
      final dateOnly = DateTime(2025, 1, 15);
      final log = CompletionLog(
        habitId: 'daily-check',
        date: dateOnly,
        isCompleted: false,
      );

      expect(log.date.hour, equals(0));
      expect(log.date.minute, equals(0));
      expect(log.date.second, equals(0));
    });

    test('should handle multiple logs for same habit on different dates', () {
      final date1 = DateTime(2025, 1, 14);
      final date2 = DateTime(2025, 1, 15);

      final log1 = CompletionLog(
        habitId: 'same-habit',
        date: date1,
        isCompleted: true,
      );

      final log2 = CompletionLog(
        habitId: 'same-habit',
        date: date2,
        isCompleted: false,
      );

      expect(log1.habitId, equals(log2.habitId));
      expect(log1.date, isNot(equals(log2.date)));
      expect(log1.isCompleted, isNot(equals(log2.isCompleted)));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_habits/models/mood_log.dart';

void main() {
  group('MoodLog', () {
    late DateTime testDate;
    late DateTime todayDate;

    setUp(() {
      testDate = DateTime(2025, 1, 15, 14, 30);
      todayDate = DateTime.now();
    });

    test('should create mood log with valid rating and no note', () {
      final moodLog = MoodLog(
        date: testDate,
        rating: 4,
      );

      expect(moodLog.date, equals(testDate));
      expect(moodLog.rating, equals(4));
      expect(moodLog.note, isNull);
    });

    test('should create mood log with valid rating and note', () {
      final moodLog = MoodLog(
        date: testDate,
        rating: 3,
        note: 'Feeling okay today, had some challenges at work',
      );

      expect(moodLog.date, equals(testDate));
      expect(moodLog.rating, equals(3));
      expect(moodLog.note, equals('Feeling okay today, had some challenges at work'));
    });

    test('should handle minimum rating value (1)', () {
      final moodLog = MoodLog(
        date: testDate,
        rating: 1,
        note: 'Very difficult day',
      );

      expect(moodLog.rating, equals(1));
      expect(moodLog.note, equals('Very difficult day'));
    });

    test('should handle maximum rating value (5)', () {
      final moodLog = MoodLog(
        date: testDate,
        rating: 5,
        note: 'Amazing day! Everything went perfectly',
      );

      expect(moodLog.rating, equals(5));
      expect(moodLog.note, equals('Amazing day! Everything went perfectly'));
    });

    test('should handle middle rating value (3)', () {
      final moodLog = MoodLog(
        date: testDate,
        rating: 3,
      );

      expect(moodLog.rating, equals(3));
      expect(moodLog.note, isNull);
    });

    test('should handle today\'s date correctly', () {
      final moodLog = MoodLog(
        date: todayDate,
        rating: 4,
        note: 'Good day today',
      );

      expect(moodLog.date.day, equals(todayDate.day));
      expect(moodLog.date.month, equals(todayDate.month));
      expect(moodLog.date.year, equals(todayDate.year));
    });

    test('should handle date with specific time (time part ignored for logic)', () {
      final specificTime = DateTime(2025, 1, 15, 23, 59, 59);
      final moodLog = MoodLog(
        date: specificTime,
        rating: 2,
        note: 'Late night reflection',
      );

      expect(moodLog.date, equals(specificTime));
      expect(moodLog.rating, equals(2));
      expect(moodLog.note, equals('Late night reflection'));
    });

    test('should handle empty note string', () {
      final moodLog = MoodLog(
        date: testDate,
        rating: 3,
        note: '',
      );

      expect(moodLog.note, equals(''));
      expect(moodLog.note, isNotNull);
    });

    test('should handle long note text', () {
      final longNote = 'This is a very long note about my mood today. I had many different experiences and emotions throughout the day. Some were positive, some were challenging, but overall I learned a lot about myself.';

      final moodLog = MoodLog(
        date: testDate,
        rating: 4,
        note: longNote,
      );

      expect(moodLog.note, equals(longNote));
      expect(moodLog.note!.length, greaterThan(100));
    });

    test('should handle different dates for mood tracking', () {
      final date1 = DateTime(2025, 1, 14);
      final date2 = DateTime(2025, 1, 15);

      final moodLog1 = MoodLog(
        date: date1,
        rating: 2,
        note: 'Yesterday was tough',
      );

      final moodLog2 = MoodLog(
        date: date2,
        rating: 4,
        note: 'Today is much better',
      );

      expect(moodLog1.date, isNot(equals(moodLog2.date)));
      expect(moodLog1.rating, isNot(equals(moodLog2.rating)));
      expect(moodLog1.note, isNot(equals(moodLog2.note)));
    });

    test('should handle all valid rating values', () {
      for (int rating = 1; rating <= 5; rating++) {
        final moodLog = MoodLog(
          date: testDate,
          rating: rating,
          note: 'Rating $rating test',
        );

        expect(moodLog.rating, equals(rating));
        expect(moodLog.rating, greaterThanOrEqualTo(1));
        expect(moodLog.rating, lessThanOrEqualTo(5));
      }
    });
  });
}

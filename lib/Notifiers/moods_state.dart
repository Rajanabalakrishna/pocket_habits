import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';

import '../models/mood_log.dart';
import '../providers/providers.dart';

class MoodNotifier extends StateNotifier<List<MoodLog>> {
  final Box<MoodLog> box;

  MoodNotifier(this.box) : super(box.values.toList());

  Future<void> addMoodLog(int rating, {String? note}) async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    // Check if mood already exists for today
    final existingMoodIndex = state.indexWhere((log) =>
    log.date.year == todayStart.year &&
        log.date.month == todayStart.month &&
        log.date.day == todayStart.day);

    final moodLog = MoodLog(
      date: todayStart,
      rating: rating,
      note: note,
    );

    if (existingMoodIndex != -1) {
      // Update existing mood
      await box.putAt(existingMoodIndex, moodLog);
    } else {
      // Add new mood
      await box.add(moodLog);
    }

    state = box.values.toList();
  }

  void logMood(MoodLog mood) {
    box.add(mood);
    state = box.values.toList();
  }

  bool hasMoodForToday() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    return state.any((log) =>
    log.date.year == todayStart.year &&
        log.date.month == todayStart.month &&
        log.date.day == todayStart.day);
  }

  List<MoodLog> getWeeklyMoods() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return state.where((log) => log.date.isAfter(weekAgo)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  MoodLog? getMoodForDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);

    return state.where((log) =>
    log.date.year == dayStart.year &&
        log.date.month == dayStart.month &&
        log.date.day == dayStart.day).firstOrNull;
  }
}

final moodsProvider = StateNotifierProvider<MoodNotifier, List<MoodLog>>((ref) {
  final box = ref.watch(moodBoxProvider);
  return MoodNotifier(box);
});

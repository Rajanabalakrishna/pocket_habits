import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pocket_habits/models/habit.dart';
import 'package:pocket_habits/models/mood_log.dart';
import 'package:pocket_habits/models/completion_log.dart';

// Providers for Hive boxes
final habitBoxProvider = Provider<Box<Habit>>((ref) {
  throw UnimplementedError(); // will be overridden in main
});

final moodBoxProvider = Provider<Box<MoodLog>>((ref) {
  throw UnimplementedError();
});

final completionBoxProvider = Provider<Box<CompletionLog>>((ref) {
  throw UnimplementedError();
});

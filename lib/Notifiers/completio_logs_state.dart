import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';

import '../models/completion_log.dart';
import '../providers/providers.dart';

class CompletionNotifier extends StateNotifier<List<CompletionLog>> {
  final Box<CompletionLog> box;

  CompletionNotifier(this.box) : super(box.values.toList());

  void toggleCompletion(String habitId, DateTime date, bool completed) {
    final log = CompletionLog(habitId: habitId, date: date, isCompleted: completed);
    box.add(log);
    state = box.values.toList();
  }
}

final completionsProvider =
StateNotifierProvider<CompletionNotifier, List<CompletionLog>>((ref) {
  final box = ref.watch(completionBoxProvider);
  return CompletionNotifier(box);
});

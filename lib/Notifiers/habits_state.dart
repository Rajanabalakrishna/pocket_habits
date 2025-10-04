import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:pocket_habits/providers/providers.dart';

import '../models/habit.dart';
import '../notifications/notificartion_service.dart';

class HabitNotifier extends StateNotifier<List<Habit>> {
  final Box<Habit> box;

  HabitNotifier(this.box) : super(box.values.toList()) {
    // Schedule notifications for existing habits on startup
    _scheduleAllNotifications();
  }

  void addHabit(Habit habit) {
    box.put(habit.id, habit);
    state = box.values.toList();

    // Schedule notification for the new habit
    NotificationService().scheduleHabitReminder(habit);
    print('Added habit: ${habit.name} with reminder: ${habit.reminderTime}');
  }

  void deleteHabit(String id) {
    // Cancel notification before deleting
    NotificationService().cancelHabitReminder(id);
    box.delete(id);
    state = box.values.toList();
    print('Deleted habit with ID: $id');
  }

  void updateHabit(Habit habit) {
    box.put(habit.id, habit);
    state = box.values.toList();

    // Reschedule notification with updated details
    NotificationService().scheduleHabitReminder(habit);
    print('Updated habit: ${habit.name} with reminder: ${habit.reminderTime}');
  }

  void _scheduleAllNotifications() {
    print('Scheduling notifications for ${state.length} habits');
    for (final habit in state) {
      NotificationService().scheduleHabitReminder(habit);
    }
  }

  Future<void> rescheduleAllNotifications() async {
    print('Rescheduling all notifications');
    await NotificationService().rescheduleAllHabits(state);
  }
}

final habitsProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  final box = ref.watch(habitBoxProvider);
  return HabitNotifier(box);
});

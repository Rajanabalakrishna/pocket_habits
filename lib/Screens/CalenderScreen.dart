import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Notifiers/habits_state.dart';
import '../Notifiers/completio_logs_state.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final completions = ref.watch(completionsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Streak Calendar'),
        backgroundColor: isDarkMode ? const Color(0xFF2D3748) : Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _buildCalendarDay(day, habits, completions);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildCalendarDay(day, habits, completions, isToday: true);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildCalendarDay(day, habits, completions, isSelected: true);
              },
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(
                color: isDarkMode ? Colors.red[300] : Colors.red,
              ),
              defaultTextStyle: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              weekNumberTextStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
              weekendStyle: TextStyle(
                color: isDarkMode ? Colors.red[300] : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildStreakStats(habits, completions),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(
      DateTime day,
      List habits,
      List completions, {
        bool isToday = false,
        bool isSelected = false,
      }) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final isAllCompleted = _isAllHabitsCompleted(dayStart, habits, completions);
    final completedCount = _getCompletedHabitsCount(dayStart, completions);
    final totalHabits = habits.length;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color? backgroundColor;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    if (isSelected) {
      backgroundColor = isDarkMode ? Colors.blue[400] : Colors.blue;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = isDarkMode ? Colors.orange[400] : Colors.orange;
      textColor = Colors.white;
    } else if (isAllCompleted && totalHabits > 0) {
      backgroundColor = isDarkMode ? Colors.green[400] : Colors.green;
      textColor = Colors.white;
    } else if (completedCount > 0) {
      backgroundColor = isDarkMode
          ? Colors.green[400]!.withOpacity(0.3)
          : Colors.green.withOpacity(0.3);
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(
            color: isDarkMode ? Colors.orange[400]! : Colors.orange,
            width: 2
        )
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (totalHabits > 0)
              Text(
                '$completedCount/$totalHabits',
                style: TextStyle(
                  color: textColor,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStats(List habits, List completions) {
    final currentStreak = _getCurrentStreak(habits, completions);
    final longestStreak = _getLongestStreak(habits, completions);
    final totalCompletedDays = _getTotalCompletedDays(habits, completions);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
              'Current Streak',
              '$currentStreak days',
              isDarkMode ? Colors.green[400]! : Colors.green
          ),
          _buildStatCard(
              'Longest Streak',
              '$longestStreak days',
              isDarkMode ? Colors.blue[400]! : Colors.blue
          ),
          _buildStatCard(
              'Perfect Days',
              '$totalCompletedDays',
              isDarkMode ? Colors.purple[400]! : Colors.purple
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? color.withOpacity(0.2)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isDarkMode
                ? color.withOpacity(0.5)
                : color.withOpacity(0.3)
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode
                  ? color.withOpacity(0.9)
                  : color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _isAllHabitsCompleted(DateTime day, List habits, List completions) {
    if (habits.isEmpty) return false;

    // Only check habits that were created before or on this day
    final relevantHabits = habits.where((habit) {
      final habitCreatedDate = DateTime(
          habit.createdAt.year,
          habit.createdAt.month,
          habit.createdAt.day
      );
      final checkDate = DateTime(day.year, day.month, day.day);
      return !habitCreatedDate.isAfter(checkDate);
    }).toList();

    if (relevantHabits.isEmpty) return false;

    for (var habit in relevantHabits) {
      final isCompleted = completions.any((log) =>
      log.habitId == habit.id &&
          log.date.year == day.year &&
          log.date.month == day.month &&
          log.date.day == day.day &&
          log.isCompleted);

      if (!isCompleted) return false;
    }
    return true;
  }

  int _getCompletedHabitsCount(DateTime day, List completions) {
    return completions
        .where((log) =>
    log.date.year == day.year &&
        log.date.month == day.month &&
        log.date.day == day.day &&
        log.isCompleted)
        .length;
  }

  int _getCurrentStreak(List habits, List completions) {
    if (habits.isEmpty) return 0;

    int streak = 0;
    DateTime currentDay = DateTime.now();
    final today = DateTime(currentDay.year, currentDay.month, currentDay.day);

    // Start from today and go backwards
    currentDay = today;

    while (true) {
      final dayStart = DateTime(currentDay.year, currentDay.month, currentDay.day);

      // Skip future dates
      if (dayStart.isAfter(today)) {
        currentDay = currentDay.subtract(const Duration(days: 1));
        continue;
      }

      if (_isAllHabitsCompleted(dayStart, habits, completions)) {
        streak++;
        currentDay = currentDay.subtract(const Duration(days: 1));
      } else {
        // Break the streak if any day is incomplete
        break;
      }

      // Prevent infinite loop - don't go back more than 1 year
      if (today.difference(currentDay).inDays > 365) break;
    }

    return streak;
  }

  int _getLongestStreak(List habits, List completions) {
    if (habits.isEmpty) return 0;

    int longestStreak = 0;
    int currentStreak = 0;

    // Get the earliest habit creation date
    DateTime earliestDate = habits.isNotEmpty
        ? habits.map((h) => h.createdAt).reduce((a, b) => a.isBefore(b) ? a : b)
        : DateTime.now();

    DateTime startDate = DateTime(earliestDate.year, earliestDate.month, earliestDate.day);
    DateTime endDate = DateTime.now();

    // Check each day from start to end
    DateTime currentDate = startDate;
    while (!currentDate.isAfter(endDate)) {
      if (_isAllHabitsCompleted(currentDate, habits, completions)) {
        currentStreak++;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      } else {
        currentStreak = 0;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return longestStreak;
  }

  int _getTotalCompletedDays(List habits, List completions) {
    if (habits.isEmpty) return 0;

    // Get all unique dates from completions
    Set<DateTime> uniqueDates = completions
        .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
        .toSet();

    int totalCompletedDays = 0;
    for (DateTime date in uniqueDates) {
      if (_isAllHabitsCompleted(date, habits, completions)) {
        totalCompletedDays++;
      }
    }

    return totalCompletedDays;
  }
}

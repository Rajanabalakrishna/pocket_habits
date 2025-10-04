import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Notifiers/habits_state.dart';
import '../Notifiers/completio_logs_state.dart';
import '../Notifiers/moods_state.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final completions = ref.watch(completionsProvider);
    final moods = ref.watch(moodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar & Stats'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly Habit Completion',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildWeeklyBarChart(habits, completions),
              ),
              const SizedBox(height: 40),
              const Text(
                '7-Day Mood',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildMoodLineChart(moods),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyBarChart(List habits, List completions) {
    final weeklyData = _getWeeklyCompletionData(habits, completions);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueAccent,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dayName = _getDayName(groupIndex);
              return BarTooltipItem(
                '$dayName\n${rod.toY.round()}%',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(_getDayAbbreviation(value.toInt()), style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: weeklyData.asMap().entries.map((entry) {
          int index = entry.key;
          double percentage = entry.value;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: percentage,
                color: _getBarColor(percentage),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
      ),
    );
  }

  Widget _buildMoodLineChart(List moods) {
    final moodData = _getWeeklyMoodData(moods);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 5,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.blueAccent,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final dayName = _getDayName(barSpot.x.toInt());
                final moodLabel = _getMoodLabel(barSpot.y.toInt());
                return LineTooltipItem(
                  '$dayName\n$moodLabel (${barSpot.y.toInt()}/5)',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(_getDayAbbreviation(value.toInt()), style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: moodData,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _getWeeklyCompletionData(List habits, List completions) {
    final now = DateTime.now();
    final weeklyData = <double>[];

    // Get last 7 days
    for (int i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final dayStart = DateTime(targetDate.year, targetDate.month, targetDate.day);

      if (habits.isEmpty) {
        weeklyData.add(0.0);
        continue;
      }

      // Count completed habits for this day
      final completedCount = completions.where((log) =>
      log.date.year == dayStart.year &&
          log.date.month == dayStart.month &&
          log.date.day == dayStart.day &&
          log.isCompleted
      ).length;

      // Calculate percentage
      final percentage = (completedCount / habits.length) * 100;
      weeklyData.add(percentage.clamp(0.0, 100.0));
    }

    return weeklyData;
  }

  List<FlSpot> _getWeeklyMoodData(List moods) {
    final now = DateTime.now();
    final moodSpots = <FlSpot>[];

    // Get last 7 days
    for (int i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final dayStart = DateTime(targetDate.year, targetDate.month, targetDate.day);

      // Find mood for this day
      final moodForDay = moods.where((mood) =>
      mood.date.year == dayStart.year &&
          mood.date.month == dayStart.month &&
          mood.date.day == dayStart.day
      ).firstOrNull;

      // Only add spot if mood exists (gaps allowed as per requirement)
      if (moodForDay != null) {
        moodSpots.add(FlSpot((6 - i).toDouble(), moodForDay.rating.toDouble()));
      }
    }

    return moodSpots;
  }

  String _getDayAbbreviation(int index) {
    final now = DateTime.now();
    final targetDate = now.subtract(Duration(days: 6 - index));
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[(targetDate.weekday - 1) % 7];
  }

  String _getDayName(int index) {
    final now = DateTime.now();
    final targetDate = now.subtract(Duration(days: 6 - index));
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[(targetDate.weekday - 1) % 7];
  }

  String _getMoodLabel(int rating) {
    const labels = ['', 'Very Sad', 'Neutral', 'Happy', 'Great', 'Amazing'];
    return labels[rating];
  }

  Color _getBarColor(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else if (percentage >= 40) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
}

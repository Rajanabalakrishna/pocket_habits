import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Notifiers/completio_logs_state.dart';
import '../Notifiers/habits_state.dart';
import '../models/habit.dart';
import 'newHabit.dart';

class HabitTile extends ConsumerStatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Habit habit;

  const HabitTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.habit,
  });

  @override
  ConsumerState<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends ConsumerState<HabitTile> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _strikeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _strikeAnimation;

  bool get isCompleted {
    final completions = ref.watch(completionsProvider);
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    return completions.any((log) =>
    log.habitId == widget.habit.id &&
        log.date.year == todayStart.year &&
        log.date.month == todayStart.month &&
        log.date.day == todayStart.day &&
        log.isCompleted
    );
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _strikeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut)
    );

    _strikeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _strikeController, curve: Curves.easeInOut)
    );

    // Initialize animation state based on completion status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isCompleted) {
        _fadeController.forward();
        _strikeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _strikeController.dispose();
    super.dispose();
  }

  void _toggleCompletion() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    if (isCompleted) {
      // Mark as incomplete
      _fadeController.reverse();
      _strikeController.reverse();
      ref.read(completionsProvider.notifier).toggleCompletion(
          widget.habit.id,
          todayStart,
          false
      );
    } else {
      // Mark as complete
      _fadeController.forward();
      _strikeController.forward();
      ref.read(completionsProvider.notifier).toggleCompletion(
          widget.habit.id,
          todayStart,
          true
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 300),
      child: AnimatedBuilder(
        animation: Listenable.merge([_fadeAnimation, _strikeAnimation]),
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Dismissible(
              key: Key(widget.habit.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.delete, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              onDismissed: (direction) {
                ref.read(habitsProvider.notifier).deleteHabit(widget.habit.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.title} deleted'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewHabitPage(habitToEdit: widget.habit),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.icon,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: isCompleted
                                        ? Colors.grey.withOpacity(0.6)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: isCompleted
                                            ? Colors.grey.withOpacity(0.6)
                                            : null,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        decorationColor: Colors.green,
                                        decorationThickness: 2.0,
                                      ),
                                    ),
                                    if (widget.subtitle.isNotEmpty)
                                      Text(
                                        widget.subtitle,
                                        style: TextStyle(
                                          color: isCompleted
                                              ? Colors.grey.withOpacity(0.4)
                                              : Colors.grey,
                                          decoration: isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          decorationColor: Colors.green,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: _toggleCompletion,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Checkbox(
                                  activeColor: Colors.green,
                                  value: isCompleted,
                                  onChanged: (val) => _toggleCompletion(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Animated strike-through line
                        if (isCompleted)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: StrikeThroughPainter(_strikeAnimation.value),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for animated strike-through effect
class StrikeThroughPainter extends CustomPainter {
  final double progress;

  StrikeThroughPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final startX = size.width * 0.1;
    final endX = size.width * 0.7;
    final y = size.height * 0.5;

    final currentEndX = startX + (endX - startX) * progress;

    canvas.drawLine(
      Offset(startX, y),
      Offset(currentEndX, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(StrikeThroughPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}


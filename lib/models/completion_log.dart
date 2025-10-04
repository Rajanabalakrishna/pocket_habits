import 'package:hive/hive.dart';

part 'completion_log.g.dart'; // This file will be generated

@HiveType(typeId: 3)
class CompletionLog extends HiveObject {
  @HiveField(0)
  final String habitId;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final bool isCompleted;

  CompletionLog({
    required this.habitId,
    required this.date,
    required this.isCompleted,
  });
}
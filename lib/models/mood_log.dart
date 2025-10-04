import 'package:hive/hive.dart';

part 'mood_log.g.dart'; // This file will be generated

@HiveType(typeId: 2)
class MoodLog extends HiveObject {
  @HiveField(0)
  final DateTime date; // The date of the log (time part will be ignored)

  @HiveField(1)
  final int rating; // A value from 1 to 5

  @HiveField(2)
  final String? note; // The optional note, can be null

  MoodLog({
    required this.date,
    required this.rating,
    this.note,
  });
}
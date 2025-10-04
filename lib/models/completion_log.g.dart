// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompletionLogAdapter extends TypeAdapter<CompletionLog> {
  @override
  final int typeId = 3;

  @override
  CompletionLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletionLog(
      habitId: fields[0] as String,
      date: fields[1] as DateTime,
      isCompleted: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CompletionLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.habitId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

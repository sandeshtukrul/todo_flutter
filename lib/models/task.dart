import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  Task({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.createdAtTime,
    required this.createdAtDate,
    required this.isCompleted,
  });

  @HiveField(0) // Id
  final String id;

  @HiveField(1) // Title
  String title;

  @HiveField(2) // subTitle
  String subTitle;

  @HiveField(3) // createdTime
  String createdAtTime;

  @HiveField(4) // createdDate
  DateTime createdAtDate;

  @HiveField(5) // isCompleted
  bool isCompleted;

  /// Convert String to TimeOfDay
  TimeOfDay get createdAtTimeOfDay {
    final parts = createdAtTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // create new Task
  factory Task.create({
    required String? title,
    required String? subTitle,
    required TimeOfDay? createdAtTime,
    required DateTime? createdAtDate,
  }) {
    final time = createdAtTime ?? TimeOfDay.now();
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final timeString = '$hour:$minute $period';

    return Task(
      id: const Uuid().v1(),
      title: title ?? '',
      subTitle: subTitle ?? '',
      createdAtTime: timeString,
      createdAtDate: createdAtDate ?? DateTime.now(),
      isCompleted: false,
    );
  }
}

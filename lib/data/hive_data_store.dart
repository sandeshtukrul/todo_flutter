import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo/models/task.dart';

/// All the [CRUD] operations methods for Hive DB.
class HiveDataStore {
  /// Box Name - String
  static const boxName = 'taskBox';

  /// our current box with the saved data inside Box
  final Box<Task> box = Hive.box<Task>(boxName);

  /// Add new task to the boc
  Future<void> addTask({required Task task}) async {
    await box.put(task.id, task);
  }

  /// Show Task
  Future<Task?> getTask({required String id}) async {
    return box.get(id);
  }

  /// Update Task
  Future<void> updateTask({required Task task}) async {
    await task.save();
  }

  /// Delete Task
  Future<void> deletedTask({required Task task}) async {
    await task.delete();
  }

  /// Listen to box changes
  /// using this method we will listen to box changes and update the ui accordingly.
  ValueListenable<Box<Task>> listenToTask() => box.listenable();

  // Checks total tasks
  int countAllTasks() {
    return box.values.length;
  }

  // Checks done tasks
  int countCompletedTasks() {
    return box.values.where((task) => task.isCompleted).length;
  }

  // sorts tasks by LIFO
  List<Task> getAllTasksSortedByDateDesc() {
    final tasks = box.values.toList();
    tasks.sort((a, b) => a.createdAtDate.compareTo(b.createdAtDate));
    return tasks;
  }
}

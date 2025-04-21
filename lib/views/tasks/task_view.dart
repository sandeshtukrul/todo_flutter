import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/extensions/space_exs.dart';
import 'package:todo/main.dart';
import 'package:todo/models/task.dart';
import 'package:todo/utils/app_colors.dart';
import 'package:todo/utils/app_str.dart';
import 'package:todo/utils/constants.dart';
import 'package:todo/views/tasks/components/date_time_selection.dart';
import 'package:todo/views/tasks/components/rep_textfield.dart';
import 'package:todo/views/tasks/widget/task_view_app_bar.dart';

class TaskView extends StatefulWidget {
  const TaskView({
    super.key,
    this.task,
    required TextEditingController titleTaskController,
    required TextEditingController descriptionTaskController,
  });

  final Task? task;

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  late final TextEditingController titleTaskController;
  late final TextEditingController descriptionTaskController;

  // Local state for date and time
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;

  // helper getter to determine if we are in editing an existing task
  bool get isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      // Editing existing task: Initialize state from task
      titleTaskController = TextEditingController(text: widget.task!.title);
      descriptionTaskController =
          TextEditingController(text: widget.task!.subTitle);
      _selectedDate = widget.task!.createdAtDate;
      // Safely parse time string
      _selectedTime = _parseTimeOfDay(widget.task!.createdAtTime);
    } else {
      // Adding new task: Initialize with defaults or empty
      titleTaskController = TextEditingController();
      descriptionTaskController = TextEditingController();
      _selectedDate = DateTime.now(); // Default to now
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    titleTaskController.dispose();
    descriptionTaskController.dispose();
    super.dispose();
  }

  // Convert String to TimeOfDay
  TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return null;
    }

    try {
      final format = DateFormat.jm(); // Assumes "h:mm a" format like "1:30 PM"
      final dateTime = format.parse(timeString);
      return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    } catch (e) {
      print("Error parsing time string '$timeString': $e");
      // Optionally return TimeOfDay.now() or handle error differently
      return null;
    }
  }

  // show selected time as string format
  String _showTime(TimeOfDay? time) {
    return (time ?? TimeOfDay.now()).format(context);
  }

  // show selected date as string format
  String _showDate(DateTime? date) {
    return DateFormat('d MMM y').format(date ?? DateTime.now());
  }

  /// Main function to add new task or update existing task
  dynamic addOrUpdateTask() {
    /// Below we update current task
    final newTitle = titleTaskController.text.trim();
    final newSubTitle = descriptionTaskController.text.trim();

    // CASE 1: User wants to update an existing task
    if (isEditMode) {
      // If both are empty, show warning
      if ((newTitle.isEmpty && newSubTitle.isEmpty)) {
        updateTaskWarning(context);
        return;
      }

      try {
        widget.task!.title = newTitle;
        widget.task!.subTitle = newSubTitle;

        widget.task!.createdAtDate = _selectedDate ?? DateTime.now();
        widget.task!.createdAtTime = _showTime(_selectedTime);

        widget.task!.save();
        Navigator.pop(context);
      } catch (e) {
        updateTaskWarning(context);
      }
    }

    // CASE 2: User wants to add a new task
    else {
      if ((newTitle.isEmpty && newSubTitle.isEmpty)) {
        /// if user want to add new task but entered nothing
        emptyWarning(context);
        return;
      }

      final task = Task.create(
        title: newTitle,
        subTitle: newSubTitle,
        createdAtTime: _selectedTime ?? TimeOfDay.now(),
        createdAtDate: _selectedDate ?? DateTime.now(),
      );

      // we are adding new task to Hive Db using inherited widget
      BaseWidget.of(context).dataStore.addTask(task: task);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        /// AppBar
        appBar: TaskViewAppBar(context),

        /// Body
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// Top Side Texts
                _buildTopSideTexts(textTheme),

                /// Main Task view activity
                _buildMainTaskViewActivity(context),

                /// Bottom side button
                _buildBottomSideButtons()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSideButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isEditMode
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.center,
        children: [
          isEditMode
              ?

              /// Delete current task button
              MaterialButton(
                  onPressed: () {
                    widget.task?.delete();
                    Navigator.pop(context);
                  },
                  minWidth: 150,
                  height: 55,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: AppColors.primaryColor,
                      ),
                      5.w,
                      Text(
                        AppStr.deleteTask,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),

          /// Add or Update Task Button
          MaterialButton(
            onPressed: () {
              addOrUpdateTask();
            },
            minWidth: 150,
            height: 55,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: AppColors.primaryColor,
            child: Row(
              children: [
                Icon(
                  isEditMode ? Icons.check_circle_outline : Icons.add,
                  color: Colors.white,
                ),
                5.w,
                Text(
                  isEditMode ? AppStr.updateTaskString : AppStr.addTaskString,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMainTaskViewActivity(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      height: 530,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title of TextFiled
          Padding(
            padding: EdgeInsets.only(left: 30),
            child: Text(
              AppStr.titleOfTitleTextField,
              style: textTheme.headlineMedium,
            ),
          ),

          /// Task Title
          RepTextField(
            controller: titleTaskController,
            onFieldSubmitted: (_) {},
            onChanged: (_) {},
          ),

          10.h,

          /// Description text
          RepTextField(
            controller: descriptionTaskController,
            isForDescription: true,
            onFieldSubmitted: (_) {},
            onChanged: (_) {},
          ),

          /// Time Selection
          DateTimeSelectionWidget(
            title: AppStr.timeString,
            onTap: () async {
              TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: _selectedTime ?? TimeOfDay.now(),
              );

              if (selectedTime != null) {
                /// here i get the selected time from user.
                setState(() {
                  _selectedTime = selectedTime;
                });
              }
            },
            time: _showTime(_selectedTime),
          ),

          /// Date Selection
          DateTimeSelectionWidget(
            title: AppStr.dateString,
            onTap: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDate: _selectedDate ?? DateTime.now(),
              );

              if (selectedDate != null) {
                /// here i get the selected date from user.
                setState(() {
                  _selectedDate = selectedDate;
                });

                /// for proper formatting use intl package in dep.
              }
            },
            time: _showDate(_selectedDate),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSideTexts(TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            child: Divider(
              thickness: 2,
            ),
          ),
          RichText(
            text: TextSpan(
                text: isEditMode ? AppStr.updateCurrentTask : AppStr.addNewTask,
                style: textTheme.headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: AppStr.taskString,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ))
                ]),
          ),
          SizedBox(
            width: 70,
            child: Divider(
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }
}

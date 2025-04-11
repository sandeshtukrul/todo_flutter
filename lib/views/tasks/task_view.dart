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
    this.titleTaskController,
    this.descriptionTaskController,
    this.task,
  });

  final TextEditingController? titleTaskController;
  final TextEditingController? descriptionTaskController;
  final Task? task;

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  var title;
  var subTitle;
  TimeOfDay? time;
  DateTime? date;

  // show selected time as string format
  String showTime(TimeOfDay? time) {
    if (widget.task?.createdAtTime == null) {
      if (time == null) {
        return TimeOfDay.now().format(context);
      } else {
        return time.format(context);
      }
    } else {
      return widget.task!.createdAtTime;
    }
  }

  // show selected date as string format
  String showDate(DateTime? date) {
    if (widget.task?.createdAtDate == null) {
      if (date == null) {
        return DateFormat('d MMM y').format(DateTime.now());
      } else {
        return DateFormat('d MMM y').format(date);
      }
    } else {
      return DateFormat('d MMM y').format(widget.task!.createdAtDate);
    }
  }

  // Show selected date as initial value of date picker
  DateTime showInitialDate(DateTime? date) {
    if (widget.task?.createdAtDate == null) {
      if (date == null) {
        return DateTime.now();
      } else {
        return date;
      }
    } else {
      return widget.task!.createdAtDate;
    }
  }

  // Convert String to TimeOfDay
  TimeOfDay parseTimeOfDay(String timeString) {
    final format = DateFormat.jm();
    final DateTime dateTime = format.parse(timeString);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  // Show selected time as initial value of time picker
  TimeOfDay showInitialTime(TimeOfDay? time) {
    if (widget.task?.createdAtTime == null) {
      if (time == null) {
        return TimeOfDay.now();
      } else {
        return time;
      }
    } else {
      return parseTimeOfDay(widget.task!.createdAtTime);
    }
  }

  /// Main function to add new task or update existing task
  dynamic addOrUpdateTask() {
    /// Below we update current task
    final newTitle = widget.titleTaskController?.text.trim();
    final newSubTitle = widget.descriptionTaskController?.text.trim();

    // CASE 1: User wants to update an existing task
    if (widget.task != null) {
      // If both are empty, show warning
      if ((newTitle?.isEmpty ?? true) && (newSubTitle?.isEmpty ?? true)) {
        updateTaskWarning(context);
        return;
      }

      try {
        if (newTitle?.isNotEmpty ?? false) {
          widget.task!.title = newTitle!;
        }

        if (newSubTitle?.isNotEmpty ?? false) {
          widget.task!.subTitle = newSubTitle!;
        }

        widget.task!.save();
        Navigator.pop(context);
      } catch (e) {
        updateTaskWarning(context);
      }
    }

    // CASE 2: User wants to add a new task
    else {
      if ((title?.isNotEmpty ?? false) && (subTitle?.isNotEmpty ?? false)) {
        final task = Task.create(
          title: title,
          subTitle: subTitle,
          createdAtTime: time,
          createdAtDate: date,
        );

        // we are adding new task to Hive Db using inherited widget
        BaseWidget.of(context).dataStore.addTask(task: task);

        Navigator.pop(context);
      } else {
        /// if user want to add new task but entered nothing
        emptyWarning(context);
      }
    }
  }

  // Check if task already exists
  bool isTaskAlreadyExists() {
    if (widget.titleTaskController?.text == null &&
        widget.descriptionTaskController?.text == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
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
                _buildMainTaskViewActivity(
                  textTheme,
                  context,
                ),

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
        mainAxisAlignment: isTaskAlreadyExists()
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.center,
        children: [
          isTaskAlreadyExists()
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
                  Icons.add,
                  color: Colors.white,
                ),
                5.w,
                Text(
                  isTaskAlreadyExists()
                      ? AppStr.updateTaskString
                      : AppStr.addTaskString,
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

  Widget _buildMainTaskViewActivity(TextTheme textTheme, BuildContext context) {
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
            controller: widget.titleTaskController,
            onFieldSubmitted: (String inputTitle) {
              title = inputTitle;
            },
            onChanged: (String inputTitle) {
              title = inputTitle;
            },
          ),

          10.h,

          /// Description text
          RepTextField(
            controller: widget.descriptionTaskController,
            isForDescription: true,
            onFieldSubmitted: (String inputSubTitle) {
              subTitle = inputSubTitle;
            },
            onChanged: (String inputSubTitle) {
              subTitle = inputSubTitle;
            },
          ),

          /// Time Selection
          DateTimeSelectionWidget(
            title: AppStr.timeString,
            onTap: () async {
              TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: showInitialTime(time),
              );

              if (selectedTime != null) {
                final formattedTime = selectedTime.format(context);

                /// here i get the selected time from user.
                setState(() {
                  if (widget.task?.createdAtTime == null) {
                    time = selectedTime;
                  } else {
                    widget.task?.createdAtTime = formattedTime;
                  }
                });
              }
            },
            time: showTime(time),
          ),

          /// Date Selection
          DateTimeSelectionWidget(
            title: AppStr.dateString,
            onTap: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDate: showInitialDate(date),
              );

              if (selectedDate != null) {
                /// here i get the selected date from user.
                setState(() {
                  if (widget.task?.createdAtDate == null) {
                    date = selectedDate;
                  } else {
                    widget.task?.createdAtDate = selectedDate;
                  }
                });

                /// for proper formatting use intl package in dep.
              }
            },
            time: showDate(date),
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
                text: isTaskAlreadyExists()
                    ? AppStr.updateCurrentTask
                    : AppStr.addNewTask,
                style: textTheme.headlineLarge,
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

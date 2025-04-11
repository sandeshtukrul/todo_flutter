import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:todo/data/hive_data_store.dart';
import 'package:todo/extensions/space_exs.dart';
import 'package:todo/main.dart';
import 'package:todo/models/task.dart';
import 'package:todo/utils/app_colors.dart';
import 'package:todo/utils/app_str.dart';
import 'package:todo/utils/constants.dart';
import 'package:todo/views/home/components/slider_drawer.dart';
import 'package:todo/views/home/widget/fab.dart';
import 'package:todo/views/home/widget/task_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GlobalKey<SliderDrawerState> drawerKey = GlobalKey<SliderDrawerState>();
  late HiveDataStore? base;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      base = BaseWidget.of(context).dataStore;
    } catch (e, s) {
      log(
        'BaseWidget not found in context',
        name: 'home_view.dart',
        error: e,
        stackTrace: s,
      );
      // Handle fallback or exit early
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder(
      valueListenable: base!.listenToTask(),
      builder: (ctx, Box<Task> box, Widget? child) {
        var tasks = box.values.toList();

        /// Sort tasks by date
        base!.getAllTasksSortedByDateDesc();

        return Scaffold(
          backgroundColor: Colors.white,

          // FAB
          floatingActionButton: const Fab(),

          /// Body
          body: SafeArea(
            child: SliderDrawer(
              key: drawerKey,
              isDraggable: false,
              animationDuration: 1000,

              /// Drawer
              /// As of now drawer is implemented partially with dummy data and not working fully.
              slider: CustomDrawer(),

              appBar: SliderAppBar(
                config: SliderAppBarConfig(
                  drawerIconSize: 36,
                  title: SizedBox(),

                  /// trash button
                  trailing: IconButton(
                    onPressed: () async {
                      if (base!.box.isEmpty) {
                        await noTaskWarning(context);
                      } else {
                        final confirmed = await deleteAllTask(context);

                        // only use context if still mounted
                        if (confirmed && context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(AppStr.allTaskDeleted),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                        }
                      }
                    },
                    icon: Icon(
                      Icons.delete_forever_rounded,
                      size: 36,
                    ),
                  ),
                ),
              ),

              /// Main Body
              child: _buildHomeBody(
                textTheme,
                base!,
                tasks,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Home Body
  Widget _buildHomeBody(
      TextTheme textTheme, HiveDataStore base, List<Task> tasks) {
    //  benefit of using these variables is that it loops only once on every build
    final completedTasks = base.countCompletedTasks();
    final totalTasks = base.countAllTasks();

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          /// Header
          HeaderWidget(
            completedTasks: completedTasks,
            totalTasks: totalTasks,
            textTheme: textTheme,
            tasks: tasks,
          ),

          /// Divider
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Divider(
              thickness: 2,
              indent: 100,
            ),
          ),

          /// Task List
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: tasks.isNotEmpty

                  /// Task List is not empty
                  ? _taskList(tasks, base)

                  /// Task list is empty
                  : _emptyList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskList(List<Task> tasks, HiveDataStore base) {
    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          var task = tasks[index];
          return Dismissible(
            key: Key(task.id),
            direction: DismissDirection.horizontal,
            onDismissed: (_) {
              /// Delete Task from DB and show snackbar to undo

              final deletedTask = task;

              // First, remove the task from the list immediately
              setState(() {
                base.deletedTask(task: deletedTask);
              });

              // Then show a Snackbar for Undo
              ScaffoldMessenger.of(context)
                  .clearSnackBars(); // clear previous ones
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Task deleted'),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      setState(() {
                        base.addTask(task: deletedTask);
                      });
                    },
                  ),
                ),
              );
            },
            background: Row(
              children: [
                25.w,
                Icon(
                  Icons.delete_outline,
                  color: Colors.grey,
                ),
                8.w,
                Text(
                  AppStr.deletedTask,
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
            child: TaskWidget(
              task: task,
            ),
          );
        });
  }

  Widget _emptyList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeIn(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Lottie.asset(
              lottieURL,
              animate: true,
              repeat: false,
            ),
          ),
        ),
        FadeInUp(
          from: 30,
          child: const Text(AppStr.doneAllTask),
        ),
      ],
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.textTheme,
    required this.tasks,
  });

  final int completedTasks;
  final dynamic totalTasks;
  final TextTheme textTheme;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Progress Indicator
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              value: totalTasks == 0 ? 0.0 : completedTasks / totalTasks,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
            ),
          ),

          /// Space
          25.w,

          /// Main Title
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStr.mainTitle,
                style: textTheme.displayLarge,
              ),
              3.h,
              Text(
                tasks.isEmpty
                    ? 'No Task'
                    : '$completedTasks of $totalTasks tasks',
                style: textTheme.titleMedium,
              ),
            ],
          )
        ],
      ),
    );
  }
}

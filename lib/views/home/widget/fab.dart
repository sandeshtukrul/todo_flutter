import 'package:flutter/material.dart';
import 'package:todo/utils/app_colors.dart';
import 'package:todo/views/tasks/task_view.dart';

class Fab extends StatelessWidget {
  /// FAB For Adding Task
  const Fab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskView(),
          ),
        );
      },
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 10,
        child: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            )),
      ),
    );
  }
}

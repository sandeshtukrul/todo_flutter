import 'package:flutter/material.dart';
import 'package:todo/extensions/space_exs.dart';

class TaskViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final BuildContext context;

  const TaskViewAppBar(this.context, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: preferredSize.height,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Row(
        children: [
          20.w,
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(56 + MediaQuery.of(context).padding.top);
}

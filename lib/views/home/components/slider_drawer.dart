import 'package:flutter/material.dart';
import 'package:todo/extensions/space_exs.dart';
import 'package:todo/utils/app_colors.dart';
import 'package:todo/utils/constants.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});

  /// Icons
  final List<IconData> icons = [
    Icons.home,
    Icons.person_2,
    Icons.settings,
    Icons.info_rounded
  ];

  /// Texts
  final List<String> texts = [
    'Home',
    'Profile',
    'Settings',
    'Details',
  ];

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradientColor,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(avatarURL),
          ),
          8.h,
          Text(
            'Rahul Devlekar',
            style: textTheme.displayMedium,
          ),
          Text(
            'Flutter developer',
            style: textTheme.displaySmall,
          ),
          Container(
            margin: EdgeInsets.symmetric(
              vertical: 30,
              horizontal: 10,
            ),
            width: double.infinity,
            height: 300,
            child: ListView.builder(
              itemCount: icons.length,
              itemBuilder: (
                BuildContext context,
                int index,
              ) {
                return InkWell(
                  onTap: () {
                    print('${texts[index]} tapped');
                  },
                  child: Container(
                    margin: EdgeInsets.all(3),
                    child: ListTile(
                      leading: Icon(
                        icons[index],
                        color: Colors.white,
                        size: 30,
                      ),
                      title: Text(
                        texts[index],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

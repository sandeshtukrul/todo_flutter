import 'package:flutter/material.dart';

extension IntExtension on int? {
  int validate({int value = 0}) {
    return this ?? value;
  }

  // vertical spacing
  Widget get h => SizedBox(
        height: this?.toDouble(),
      );

  // horizontal spacing
  Widget get w => SizedBox(
        width: this?.toDouble(),
      );
}

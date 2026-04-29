import 'package:classified/utils/app_color.dart';
import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  final double? size;
  final double strokeWidth;
  final Color? color;

  const CustomLoader({
    super.key,
    this.size,
    this.strokeWidth = 2.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      strokeWidth: strokeWidth,
      color: color ?? AppColor.buttonColor,
    );

    if (size != null) {
      return SizedBox(
        width: size,
        height: size,
        child: indicator,
      );
    }

    return indicator;
  }
}

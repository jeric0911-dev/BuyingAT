import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final Color? unratedColor;

  const RatingBar({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
    this.unratedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(
            Icons.star,
            size: size.sp,
            color: color ?? Colors.amber,
          );
        } else if (index == rating.floor() && rating % 1 > 0) {

          return Icon(
            Icons.star_half,
            size: size.sp,
            color: color ?? Colors.amber,
          );
        } else {

          return Icon(
            Icons.star_border,
            size: size.sp,
            color: unratedColor ?? Colors.grey.shade400,
          );
        }
      }),
    );
  }
} 
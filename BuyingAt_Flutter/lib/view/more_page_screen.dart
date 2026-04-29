import 'package:classified/model/more_page_model.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import '../../../widget/custom_app_bar.dart';
import '../../utils/app_color.dart';

class MorePageScreen extends StatefulWidget {
  const MorePageScreen({super.key});

  @override
  State<MorePageScreen> createState() => _MorePageScreenState();
}


class _MorePageScreenState extends State<MorePageScreen> {

  late dynamic title;
  late MorePageData value;

  @override
  void initState() {
    super.initState();
    title = Get.arguments?['title'];
    value = Get.arguments?['value'];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
      ),

      body: Padding(
        padding: EdgeInsets.only(
            left: 16.w, right: 16.w, top: 10.h,
        ),
        child: SingleChildScrollView(
          child: HtmlWidget(
              value.content ?? " ",
              textStyle: sansBold.copyWith(color: AppColor.textColor,fontSize: 16.sp,height: 1.5.h)
          ),
        ),
      ),
    );
  }
}
import 'package:classified/utils/app_color.dart';
import 'package:classified/widget/custom_snackbar_widget.dart';
import 'package:classified/widget/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../routes/app_routes.dart';
import '../transition/fade_transition.dart';
import '../utils/app_image.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchText = TextEditingController();
  final FocusNode fSearchText = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(fSearchText);
    });
  }

  @override
  void dispose() {
    fSearchText.unfocus();
    searchText.dispose();
    fSearchText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backGround,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: CustomTextFieldWidget(
            controller: searchText,
            focusNode: fSearchText,
            isSuffixWidget: true,
            hintText: 'Search for anything...',
            inputType: TextInputType.text,
            inputAction: TextInputAction.search,
            onSubmit: (value) {
              if (searchText.text.isNotEmpty) {
                FadeScreenTransition(
                  routeName: Routes.searchResultsRoute,
                  arguments: {
                    'searchQuery': searchText.text.trim(),
                  },
                ).navigate();
              } else {
                showCustomSnackBar('Please write search key');
              }
            },
            suffixWidget: InkWell(
              onTap: () {
                if (searchText.text.isNotEmpty) {
                  FadeScreenTransition(
                    routeName: Routes.searchResultsRoute,
                    arguments: {
                      'searchQuery': searchText.text.trim(),
                    },
                  ).navigate();
                } else {
                  showCustomSnackBar('Please write search key');
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SvgPicture.asset(AppImage.icSearchTwo),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

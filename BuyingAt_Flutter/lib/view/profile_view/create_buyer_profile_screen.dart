import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controller/navigation_controller.dart';
import '../../controller/user_profile_controller.dart';
import '../../routes/app_routes.dart';
import '../../service/api/api_client.dart';
import '../../utils/_constant.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_image.dart';
import '../../utils/app_text.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_text_field_widget.dart';

class CreateBuyerProfileScreen extends StatefulWidget {
  const CreateBuyerProfileScreen({super.key});

  @override
  State<CreateBuyerProfileScreen> createState() => _CreateBuyerProfileScreenState();
}

class _CreateBuyerProfileScreenState extends State<CreateBuyerProfileScreen> {
  late UserProfileController userProfileController;

  @override
  void initState() {
    super.initState();
    final apiClient = Get.find<ApiClient>();
    userProfileController = Get.put(UserProfileController(apiClient: apiClient), tag: 'create_profile');
  }

  @override
  void dispose() {
    Get.delete<UserProfileController>(tag: 'create_profile');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        title: "Create Buyer Profile",
        onTapBack: () {
          Get.back();
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40.h),
            
            // Avatar Section
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 96.w,
                      height: 96.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.buttonColor,
                          width: 2.sp,
                        ),
                        color: AppColor.ghostWhite,
                      ),
                      child: Obx(() {
                        return userProfileController.avatarPreview.value.isNotEmpty
                            ? ClipOval(
                                child: Image.file(
                                  File(userProfileController.avatarPreview.value),
                                  width: 96.w,
                                  height: 96.w,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.person,
                                  size: 48.w,
                                  color: AppColor.coolGray21,
                                ),
                              );
                      }),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          userProfileController.pickImage();
                        },
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: AppColor.buttonColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColor.white,
                              width: 2.sp,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 16.w,
                            color: AppColor.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  "Avatar",
                  style: sansReg.copyWith(
                    fontSize: 14.sp,
                    color: AppColor.textColor,
                  ),
                ),
              ],
            ),

            SizedBox(height: 32.h),

            // Bio Field
            CustomTextFieldWidget(
              controller: userProfileController.bioController,
              focusNode: userProfileController.fBio,
              showTitle: true,
              titleText: "Bio",
              hintText: "Please tell us the type of cards you are looking for (text only, no links or contact info)",
              inputType: TextInputType.multiline,
              maxLines: 8,
              capitalization: TextCapitalization.sentences,
            ),

            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                "Bio should contain only text. No external links, email addresses, phone numbers, or contact information allowed.",
                style: sansReg.copyWith(
                  fontSize: 12.sp,
                  color: AppColor.coolGray21,
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // Create Profile Button
            Obx(() {
              return CustomButton(
                isLoading: userProfileController.isLoading.value,
                marginRight: 0,
                marginLeft: 0,
                color: userProfileController.isFormValid.value
                    ? AppColor.buttonColor
                    : AppColor.buttonColor.withValues(alpha: .5),
                text: "CREATE PROFILE",
                borderColor: Colors.white,
                onPressed: userProfileController.isFormValid.value
                    ? () {
                        userProfileController.createOrUpdateProfile();
                      }
                    : null,
              );
            }),

            SizedBox(height: 16.h),

            // Skip Button
            TextButton(
              onPressed: () {
                // Navigate to profile page
                Get.offAllNamed(Routes.bottomNavRoute);
                try {
                  final navController = Get.find<NavigationController>();
                  navController.index.value = 3; // Profile tab
                } catch (_) {}
              },
              child: Text(
                "Skip for now",
                style: sansReg.copyWith(
                  fontSize: 14.sp,
                  color: AppColor.coolGray9,
                ),
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}


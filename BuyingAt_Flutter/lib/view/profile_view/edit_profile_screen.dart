import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../controller/user_profile_controller.dart';
import '../../controller/user_data_controller.dart';
import '../../controller/buyer_profile_controller.dart';
import '../../routes/app_routes.dart';
import '../../service/api/api_client.dart';
import '../../service/api/api_retry_manager.dart';
import '../../transition/fade_transition.dart';
import '../../utils/_constant.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/image_loader.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_text_field_widget.dart';
import '../../widget/custom_snackbar_widget.dart';
import '../../view/dialog/profile_updated_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late UserProfileController userProfileController;
  late UserDataController userDataController;
  
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final apiClient = Get.find<ApiClient>();
    userProfileController = Get.put(
      UserProfileController(apiClient: apiClient),
      tag: 'edit_profile',
    );
    userDataController = Get.find<UserDataController>();
    
    // Load existing user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final user = userDataController.userData.value;
    fullNameController.text = user?.name ?? '';
    emailController.text = user?.email ?? '';
    
    // Fetch user profile to get username and bio
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.getData(Constant.userProfileUrl);
      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success' && json['data'] != null) {
          final profile = json['data'];
          usernameController.text = profile['username'] ?? user?.userName?.toString() ?? '';
          userProfileController.bioController.text = profile['bio'] ?? '';
          if (profile['avatar'] != null && profile['avatar'].toString().isNotEmpty) {
            // Avatar will be loaded from URL in the UI
          }
        }
      }
    } catch (e) {
      // If profile doesn't exist, use user data
      usernameController.text = user?.userName?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    Get.delete<UserProfileController>(tag: 'edit_profile');
    usernameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    await userProfileController.pickImage();
  }

  Future<void> _submitForm() async {
    final username = usernameController.text.trim();
    final bio = userProfileController.bioController.text.trim();
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    
    if (fullName.isEmpty) {
      showCustomSnackBar('Full Name is required');
      return;
    }
    
    if (email.isEmpty) {
      showCustomSnackBar('Email is required');
      return;
    }
    
    // Validate email format
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      showCustomSnackBar('Please enter a valid email address');
      return;
    }
    
    if (username.isEmpty) {
      showCustomSnackBar('Username is required');
      return;
    }
    
    if (bio.isEmpty) {
      showCustomSnackBar('Bio is required');
      return;
    }
    
    final bioValidation = userProfileController.validateBio(bio);
    if (bioValidation != null) {
      showCustomSnackBar(bioValidation);
      return;
    }

    userProfileController.isLoading.value = true;

    try {
      // First, update user data (name and email)
      final user = userDataController.userData.value;
      if (user?.id != null) {
        final updateMeBody = {
          'name': fullName,
          'email': email,
        };
        
        final updateMeResponse = await userProfileController.apiClient.postData(
          Constant.updateMeUrl,
          updateMeBody,
        );
        
        if (updateMeResponse == null || updateMeResponse.statusCode != 200) {
          showCustomSnackBar('Failed to update user information');
          userProfileController.isLoading.value = false;
          return;
        }
      }
      
      // Then, update user profile (username, bio, avatar)
      var body = {
        'username': username,
        'bio': bio,
      };

      var multipartBody = <MultipartBody>[];
      
      if (userProfileController.avatarFile.value != null) {
        multipartBody.add(MultipartBody("avatar", userProfileController.avatarFile.value));
      }

      http.Response? response = await userProfileController.apiClient.postMultipartData(
        Constant.userProfileUrl,
        body,
        multipartBody,
      );

      if (response.statusCode == 200) {
        // Refresh user data
        userDataController.fetchUserData(isReload: true);
        // Refresh buyer profile if it exists
        try {
          final buyerProfileController = Get.find<BuyerProfileController>(tag: 'buyer_profile');
          buyerProfileController.fetchBuyerProfile();
        } catch (_) {}
        
        // Close the edit profile screen first
        Get.back();
        
        // Show success alert
        Get.dialog(
          AlertDialog(
            title: Text(
              'Success',
              style: sansSemiBold.copyWith(
                fontSize: 18.sp,
                color: AppColor.primaryColor,
              ),
            ),
            content: Text(
              'Profile updated successfully!',
              style: sansReg.copyWith(
                fontSize: 14.sp,
                color: AppColor.primaryColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'OK',
                  style: sansMedium.copyWith(
                    fontSize: 14.sp,
                    color: AppColor.buttonColor,
                  ),
                ),
              ),
            ],
          ),
          barrierDismissible: true,
        );
      } else {
        final responseBody = response.body;
        try {
          final json = jsonDecode(responseBody);
          final message = json['message'] ?? 'Failed to update profile';
          showCustomSnackBar(message);
        } catch (_) {
          showCustomSnackBar("Failed to update profile");
        }
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong! Please try again");
    } finally {
      userProfileController.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        title: 'Profile Settings',
        onTapBack: () => Get.back(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            
            Text(
              'ACCOUNT SETTING',
              style: sansSemiBold.copyWith(
                fontSize: 18.sp,
                color: AppColor.primaryColor,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Profile Picture and Personal Information
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Stack(
                  children: [
                    Obx(() {
                      final user = userDataController.userData.value;
                      final hasPreview = userProfileController.avatarPreview.value.isNotEmpty;
                      final hasExisting = user?.profileImg != null && user!.profileImg!.isNotEmpty;
                      
                      return Container(
                        width: 96.w,
                        height: 96.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.ghostWhite,
                          border: Border.all(color: AppColor.coolGray17, width: 1),
                        ),
                        child: hasPreview
                            ? ClipOval(
                                child: Image.file(
                                  File(userProfileController.avatarPreview.value),
                                  width: 96.w,
                                  height: 96.w,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : hasExisting
                                ? ClipOval(
                                    child: ImageLoader(
                                      url: '${Constant.imageBaseUrl}${user.profileImg!.startsWith('/') ? user.profileImg!.substring(1) : user.profileImg}',
                                      width: 96.w,
                                      height: 96.w,
                                      boxFit: BoxFit.cover,
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 48.w,
                                      color: AppColor.coolGray21,
                                    ),
                                  ),
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: AppColor.buttonColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColor.white, width: 2.sp),
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
                
                SizedBox(width: 24.w),
                
                // Personal Information
                Expanded(
                  child: Column(
                    children: [
                      CustomTextFieldWidget(
                        controller: fullNameController,
                        hintText: 'Full Name',
                        showTitle: true,
                        titleText: 'Full Name',
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFieldWidget(
                        controller: emailController,
                        hintText: 'Email',
                        showTitle: true,
                        titleText: 'Email',
                        inputType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFieldWidget(
                        controller: usernameController,
                        hintText: 'Username',
                        showTitle: true,
                        titleText: 'Username',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Bio Field
            CustomTextFieldWidget(
              controller: userProfileController.bioController,
              focusNode: userProfileController.fBio,
              showTitle: true,
              titleText: 'Bio',
              hintText: 'Tell us about yourself (text only, no links or contact info)...',
              inputType: TextInputType.multiline,
              maxLines: 6,
              capitalization: TextCapitalization.sentences,
            ),
            
            SizedBox(height: 8.h),
            Text(
              'Bio should contain only text. No external links, email addresses, phone numbers, or contact information allowed.',
              style: sansReg.copyWith(
                fontSize: 12.sp,
                color: AppColor.coolGray21,
              ),
            ),
            
            SizedBox(height: 32.h),
            
            // Save Changes Button
            Obx(() => CustomButton(
              text: userProfileController.isLoading.value ? 'Saving...' : 'SAVE CHANGES',
              height: 40.h,
              isLoading: userProfileController.isLoading.value,
              onPressed: userProfileController.isLoading.value ? null : _submitForm,
            )),
            
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}


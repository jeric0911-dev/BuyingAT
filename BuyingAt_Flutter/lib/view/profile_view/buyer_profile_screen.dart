import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/buyer_profile_controller.dart';
import '../../controller/user_data_controller.dart';
import '../../model/buyer_profile_model.dart';
import '../../routes/app_routes.dart';
import '../../service/api/api_client.dart';
import '../../transition/fade_transition.dart';
import '../../utils/_constant.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../utils/image_loader.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/custom_button.dart';

class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  late BuyerProfileController buyerProfileController;
  late UserDataController userDataController;
  var userProfile = Rx<Map<String, dynamic>?>(null);

  @override
  void initState() {
    super.initState();
    final apiClient = Get.find<ApiClient>();
    buyerProfileController = Get.put(
      BuyerProfileController(apiClient: apiClient),
      tag: 'buyer_profile',
    );
    userDataController = Get.find<UserDataController>();
    
    // Fetch buyer profile data and user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      buyerProfileController.fetchBuyerProfile();
      _fetchUserProfile();
    });
  }

  Future<void> _fetchUserProfile() async {
    try {
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.getData(Constant.userProfileUrl);
      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success' && json['data'] != null) {
          userProfile.value = json['data'];
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when returning from create/update screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      buyerProfileController.fetchBuyerProfile();
      _fetchUserProfile();
    });
  }

  @override
  void dispose() {
    Get.delete<BuyerProfileController>(tag: 'buyer_profile');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        title: 'Buyer Profile',
        onTapBack: () => Get.back(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            
            // User Profile Card
            _buildUserProfileCard(),
            
            SizedBox(height: 24.h),
            
            // Buyer Profile Section
            Obx(() {
              if (buyerProfileController.isLoading.value) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.h),
                    child: CircularProgressIndicator(color: AppColor.buttonColor),
                  ),
                );
              }
              
              if (buyerProfileController.hasProfile.value && 
                  buyerProfileController.buyerProfile.value != null) {
                return _buildBuyerProfileCard(buyerProfileController.buyerProfile.value!);
              } else {
                return _buildCreateBuyerProfileCard();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Obx(() {
      final user = userDataController.userData.value;
      // Get user profile info from buyer profile or UserData (use cached data)
      final buyerProfile = buyerProfileController.buyerProfile.value;
      final buyerUserProfile = buyerProfile?.user?.profile;
      
      final username = buyerUserProfile?.username ?? 
                       user?.userName?.toString() ?? 
                       user?.name ?? 
                       'User';
      final bio = buyerUserProfile?.bio ?? 
                  'No bio available';
      
      // Get avatar from multiple sources with proper fallback
      String? avatar;
      if (buyerUserProfile?.avatar != null && buyerUserProfile!.avatar!.isNotEmpty) {
        avatar = buyerUserProfile!.avatar;
      } else if (user?.profileImg != null && user!.profileImg!.isNotEmpty) {
        avatar = user!.profileImg;
      }
      
      // Clean avatar path (remove leading slash if present)
      if (avatar != null && avatar.startsWith('/')) {
        avatar = avatar.substring(1);
      }
      
      final initials = username.isNotEmpty
          ? username.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
          : 'U';

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.coolGray17, width: 1),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'USER PROFILE',
              style: sansSemiBold.copyWith(
                fontSize: 16.sp,
                color: AppColor.primaryColor,
              ),
            ),
            Divider(color: AppColor.coolGray17, thickness: 1),
            SizedBox(height: 16.h),
            
            // Avatar and Name
            Row(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.buttonColor.withOpacity(0.1),
                  ),
                  child: avatar != null && avatar.isNotEmpty
                      ? ClipOval(
                          child: ImageLoader(
                            url: '${Constant.imageBaseUrl}$avatar',
                            width: 64.w,
                            height: 64.w,
                            boxFit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            initials,
                            style: sansSemiBold.copyWith(
                              fontSize: 24.sp,
                              color: AppColor.buttonColor,
                            ),
                          ),
                        ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: sansSemiBold.copyWith(
                          fontSize: 18.sp,
                          color: AppColor.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Bio
            if (bio.isNotEmpty && bio != 'No bio available')
              Text(
                bio,
                style: sansReg.copyWith(
                  fontSize: 14.sp,
                  color: AppColor.primaryColor,
                ),
              ),
            
            SizedBox(height: 16.h),
            
            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'EDIT PROFILE',
                height: 40.h,
                onPressed: () {
                  FadeScreenTransition(routeName: Routes.editProfileRoute).navigate();
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBuyerProfileCard(BuyerProfile profile) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.coolGray17, width: 1),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BUYER PROFILE',
            style: sansSemiBold.copyWith(
              fontSize: 16.sp,
              color: AppColor.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Avatar and Name
          Row(
            children: [
              Obx(() {
                final user = userDataController.userData.value;
                final buyerProfile = buyerProfileController.buyerProfile.value;
                final userProfile = buyerProfile?.user?.profile;
                
                // Get avatar from multiple sources with proper fallback
                String? avatar;
                if (userProfile?.avatar != null && userProfile!.avatar!.isNotEmpty) {
                  avatar = userProfile!.avatar;
                } else if (user?.profileImg != null && user!.profileImg!.isNotEmpty) {
                  avatar = user!.profileImg;
                }
                
                // Clean avatar path (remove leading slash if present)
                if (avatar != null && avatar.startsWith('/')) {
                  avatar = avatar.substring(1);
                }
                
                final username = userProfile?.username ?? user?.userName?.toString() ?? user?.name ?? 'Buyer';
                final initials = username.isNotEmpty
                    ? username.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
                    : 'U';
                
                return Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.buttonColor.withOpacity(0.1),
                  ),
                  child: avatar != null && avatar.isNotEmpty
                      ? ClipOval(
                          child: ImageLoader(
                            url: '${Constant.imageBaseUrl}$avatar',
                            width: 64.w,
                            height: 64.w,
                            boxFit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            initials,
                            style: sansSemiBold.copyWith(
                              fontSize: 24.sp,
                              color: AppColor.buttonColor,
                            ),
                          ),
                        ),
                );
              }),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final user = userDataController.userData.value;
                      final buyerProfile = buyerProfileController.buyerProfile.value;
                      final userProfile = buyerProfile?.user?.profile;
                      final username = userProfile?.username ?? user?.userName?.toString() ?? user?.name ?? 'Buyer';
                      return Text(
                        username,
                        style: sansSemiBold.copyWith(
                          fontSize: 18.sp,
                          color: AppColor.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                    SizedBox(height: 4.h),
                    Text(
                      'Buyer',
                      style: sansReg.copyWith(
                        fontSize: 14.sp,
                        color: AppColor.coolGray21,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Interested Categories
          if (profile.categories != null && profile.categories!.isNotEmpty) ...[
            Text(
              'Interested in:',
              style: sansReg.copyWith(
                fontSize: 12.sp,
                color: AppColor.coolGray21,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                ...profile.categories!.take(3).map((category) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.green.shade200, width: 1),
                    ),
                    child: Text(
                      category,
                      style: sansReg.copyWith(
                        fontSize: 12.sp,
                        color: Colors.green.shade700,
                      ),
                    ),
                  );
                }),
                if (profile.categories!.length > 3)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColor.coolGray17,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '+${profile.categories!.length - 3} more',
                      style: sansReg.copyWith(
                        fontSize: 12.sp,
                        color: AppColor.coolGray21,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
          
          // Budget Range
          if (profile.budgetMin != null || profile.budgetMax != null) ...[
            Text(
              'Budget Range:',
              style: sansReg.copyWith(
                fontSize: 12.sp,
                color: AppColor.coolGray21,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '\$${profile.budgetMin ?? 0} - \$${profile.budgetMax ?? 'No limit'}',
              style: sansMedium.copyWith(
                fontSize: 14.sp,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
          ],
          
          // Tags
          if (profile.buyerTags != null && profile.buyerTags!.isNotEmpty) ...[
            Text(
              'Tags:',
              style: sansReg.copyWith(
                fontSize: 12.sp,
                color: AppColor.coolGray21,
              ),
            ),
            SizedBox(height: 4.h),
            Wrap(
              spacing: 4.w,
              runSpacing: 4.h,
              children: [
                ...profile.buyerTags!.take(3).map((tag) {
                  return Text(
                    tag.tagName ?? '',
                    style: sansReg.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.primaryColor,
                    ),
                  );
                }),
                if (profile.buyerTags!.length > 3)
                  Text(
                    ', +${profile.buyerTags!.length - 3} more',
                    style: sansReg.copyWith(
                      fontSize: 14.sp,
                      color: AppColor.primaryColor,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
          
          // Edit Buyer Profile Button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'EDIT BUYER PROFILE',
              height: 40.h,
              onPressed: () {
                FadeScreenTransition(
                  routeName: Routes.editBuyerProfileRoute,
                  arguments: {'isEditMode': true},
                ).navigate();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateBuyerProfileCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.coolGray17, width: 1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Text(
            'Complete Your Buyer Profile',
            style: sansSemiBold.copyWith(
              fontSize: 18.sp,
              color: AppColor.primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create your buyer profile with Categories and Tags.',
            style: sansReg.copyWith(
              fontSize: 14.sp,
              color: AppColor.coolGray21,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          CustomButton(
            text: 'Create Buyer Profile',
            height: 40.h,
            onPressed: () {
              FadeScreenTransition(
                routeName: Routes.editBuyerProfileRoute,
                arguments: {'isEditMode': false},
              ).navigate();
            },
          ),
        ],
      ),
    );
  }
}


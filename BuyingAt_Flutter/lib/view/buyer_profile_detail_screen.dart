import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controller/buyer_profile_detail_controller.dart';
import '../model/buyer_profile_model.dart';
import '../routes/app_routes.dart';
import '../service/api/api_client.dart';
import '../transition/fade_transition.dart';
import '../utils/_constant.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/app_image.dart';
import '../utils/image_loader.dart';
import '../widget/custom_app_bar.dart';
import '../widget/custom_button.dart';
import '../widget/custom_snackbar_widget.dart';
import '../widget/user_status_badge.dart';
import '../controller/message_controller.dart';
import '../controller/user_data_controller.dart';
import '../utils/session_manager.dart';

class BuyerProfileDetailScreen extends StatefulWidget {
  const BuyerProfileDetailScreen({super.key});

  @override
  State<BuyerProfileDetailScreen> createState() => _BuyerProfileDetailScreenState();
}

class _BuyerProfileDetailScreenState extends State<BuyerProfileDetailScreen> {
  late BuyerProfileDetailController buyerProfileDetailController;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    final profileId = args?['profileId'] as int?;
    
    if (profileId == null) {
      showCustomSnackBar("Invalid profile ID");
      Get.back();
      return;
    }

    final apiClient = Get.find<ApiClient>();
    buyerProfileDetailController = Get.put(
      BuyerProfileDetailController(apiClient: apiClient, profileId: profileId),
      tag: 'buyer_profile_detail_$profileId',
    );
    buyerProfileDetailController.fetchBuyerProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        title: "Buyer Profile",
      ),
      body: Obx(() {
        if (buyerProfileDetailController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.buttonColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Loading buyer profile...',
                  style: sansReg.copyWith(
                    color: AppColor.primaryColor,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          );
        }

        final profile = buyerProfileDetailController.buyerProfile.value;
        
        if (profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppImage.icNoData,
                  height: 200.h,
                  width: 275.w,
                ),
                SizedBox(height: 29.h),
                Text(
                  'Buyer Profile Not Found',
                  style: sansSemiBold.copyWith(
                    color: AppColor.primaryColor,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'The buyer profile you\'re looking for doesn\'t exist.',
                  style: sansReg.copyWith(
                    color: AppColor.coolGray21,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                CustomButton(
                  text: 'Back to Buyer Profiles',
                  width: 200.w,
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(profile),
              
              SizedBox(height: 24.h),
              
              // Categories Section
              _buildCategoriesSection(profile),
              
              SizedBox(height: 16.h),
              
              // Budget Range Section
              _buildBudgetSection(profile),
              
              SizedBox(height: 16.h),
              
              // Tags Section
              _buildTagsSection(profile),
              
              SizedBox(height: 16.h),
              
              // Preferences Section
              _buildPreferencesSection(profile),
              
              SizedBox(height: 16.h),
              
              // Profile Link Section
              _buildProfileLinkSection(profile),
              
              SizedBox(height: 24.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuyerProfile profile) {
    final user = profile.user;
    final username = user?.profile?.username ?? user?.name ?? 'Buyer';
    final bio = user?.profile?.bio ?? 'No bio available';
    final email = user?.email ?? '';
    final avatar = user?.profile?.avatar;
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
          // Top Row: Avatar and User Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with status badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.buttonColor.withOpacity(0.1),
                    ),
                    child: avatar != null && avatar.isNotEmpty
                        ? ClipOval(
                            child: ImageLoader(
                              url: '${Constant.imageBaseUrl}$avatar',
                              width: 80.w,
                              height: 80.w,
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
                  if (user?.id != null)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: UserStatusBadge(
                        userId: user!.id!,
                        size: 16.0,
                      ),
                    ),
                ],
              ),
              
              SizedBox(width: 16.w),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: sansBold.copyWith(
                        fontSize: 20.sp,
                        color: AppColor.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      bio,
                      style: sansReg.copyWith(
                        fontSize: 14.sp,
                        color: AppColor.coolGray21,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12.h),
                    if (email.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.email, size: 16.w, color: AppColor.coolGray21),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              email,
                              style: sansReg.copyWith(
                                fontSize: 12.sp,
                                color: AppColor.coolGray21,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Contact Button - Full Width
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Contact Buyer',
              height: 40.h,
              onPressed: () async {
                final isLoggedIn = SessionManager.getValue(kIsLOGIN, value: false);
                if (!isLoggedIn) {
                  showCustomSnackBar("Please login to contact buyers");
                  return;
                }

                final myId = SessionManager.getValue(kUserId);
                if (myId == null) {
                  showCustomSnackBar("User ID not found. Please login again.");
                  return;
                }

                if (user?.id == null) {
                  showCustomSnackBar("Buyer information not available");
                  return;
                }

                // Check if trying to contact yourself
                if (myId == user!.id) {
                  showCustomSnackBar("You cannot contact yourself");
                  return;
                }

                try {
                  final messageController = Get.find<MessageController>();
                  await messageController.createBuyerProfileConversation(
                    senderId: myId,
                    receiverId: user!.id!,
                    buyerProfileId: profile.id,
                  );
                } catch (e) {
                  showCustomSnackBar("Failed to start conversation. Please try again.");
                  print("Error creating buyer profile conversation: $e");
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuyerProfile profile) {
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
            'Interested Categories',
            style: sansSemiBold.copyWith(
              fontSize: 18.sp,
              color: AppColor.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          if (profile.categories != null && profile.categories!.isNotEmpty)
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: profile.categories!.map((category) => Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColor.buttonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  category,
                  style: sansMedium.copyWith(
                    fontSize: 14.sp,
                    color: AppColor.buttonColor,
                  ),
                ),
              )).toList(),
            )
          else
            Text(
              'No categories specified',
              style: sansReg.copyWith(
                fontSize: 14.sp,
                color: AppColor.coolGray21,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection(BuyerProfile profile) {
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
            'Budget Range',
            style: sansSemiBold.copyWith(
              fontSize: 18.sp,
              color: AppColor.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          if (profile.budgetMin != null || profile.budgetMax != null) ...[
            Text(
              '\$${profile.budgetMin ?? 0} - \$${profile.budgetMax ?? 'No limit'}',
              style: sansBold.copyWith(
                fontSize: 24.sp,
                color: AppColor.buttonColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Preferred spending range',
              style: sansReg.copyWith(
                fontSize: 12.sp,
                color: AppColor.coolGray21,
              ),
            ),
          ] else
            Text(
              'No budget range specified',
              style: sansReg.copyWith(
                fontSize: 14.sp,
                color: AppColor.coolGray21,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuyerProfile profile) {
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
            'Buyer Tags',
            style: sansSemiBold.copyWith(
              fontSize: 18.sp,
              color: AppColor.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          if (profile.buyerTags != null && profile.buyerTags!.isNotEmpty)
            Column(
              children: profile.buyerTags!.map((tag) => Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.coolGray17, width: 1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tag.tagName ?? '',
                          style: sansSemiBold.copyWith(
                            fontSize: 16.sp,
                            color: AppColor.primaryColor,
                          ),
                        ),
                        if (tag.tagType != null && tag.tagType!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColor.buttonColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              tag.tagType!,
                              style: sansReg.copyWith(
                                fontSize: 12.sp,
                                color: AppColor.buttonColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 16.w,
                      runSpacing: 8.h,
                      children: [
                        if (tag.cardCondition != null && tag.cardCondition!.isNotEmpty)
                          _buildTagDetail('Condition', tag.cardCondition!),
                        if (tag.purchaseVolume != null)
                          _buildTagDetail('Volume', tag.purchaseVolume.toString()),
                        if (tag.budgetTier != null && tag.budgetTier!.isNotEmpty)
                          _buildTagDetail('Tier', tag.budgetTier!),
                      ],
                    ),
                  ],
                ),
              )).toList(),
            )
          else
            Text(
              'No tags specified',
              style: sansReg.copyWith(
                fontSize: 14.sp,
                color: AppColor.coolGray21,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTagDetail(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: sansMedium.copyWith(
            fontSize: 14.sp,
            color: AppColor.coolGray21,
          ),
        ),
        Text(
          value,
          style: sansReg.copyWith(
            fontSize: 14.sp,
            color: AppColor.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuyerProfile profile) {
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
            'Preferences',
            style: sansSemiBold.copyWith(
              fontSize: 18.sp,
              color: AppColor.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          if (profile.preferences != null && profile.preferences!.isNotEmpty)
            Text(
              profile.preferences!,
              style: sansReg.copyWith(
                fontSize: 14.sp,
                color: AppColor.primaryColor,
                height: 1.5.h,
              ),
            )
          else
            Text(
              'No preferences specified',
              style: sansReg.copyWith(
                fontSize: 14.sp,
                color: AppColor.coolGray21,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileLinkSection(BuyerProfile profile) {
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
            'Profile Link',
            style: sansSemiBold.copyWith(
              fontSize: 18.sp,
              color: AppColor.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          if (profile.profileLink != null && profile.profileLink!.isNotEmpty)
            InkWell(
              onTap: () {
                // TODO: Open URL in browser
                showCustomSnackBar("Opening profile link: ${profile.profileLink}");
              },
              child: Text(
                profile.profileLink!,
                style: sansReg.copyWith(
                  fontSize: 14.sp,
                  color: AppColor.buttonColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            Text(
              'No profile link provided',
              style: sansReg.copyWith(
                fontSize: 14.sp,
                color: AppColor.coolGray21,
              ),
            ),
        ],
      ),
    );
  }
}


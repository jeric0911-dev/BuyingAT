import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controller/buyer_profiles_controller.dart';
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
import '../widget/custom_drop_dawn_btn.dart';
import '../widget/custom_dropdown_widget.dart';
import '../widget/custom_snackbar_widget.dart';
import '../widget/user_status_badge.dart';
import '../widget/custom_text_field_widget.dart';
import '../controller/message_controller.dart';
import '../utils/session_manager.dart';

class BuyerProfilesScreen extends StatefulWidget {
  const BuyerProfilesScreen({super.key});

  @override
  State<BuyerProfilesScreen> createState() => _BuyerProfilesScreenState();
}

class _BuyerProfilesScreenState extends State<BuyerProfilesScreen> {
  late BuyerProfilesController buyerProfilesController;

  @override
  void initState() {
    super.initState();
    final apiClient = Get.find<ApiClient>();
    // Use findOrPut to reuse existing controller if available (keeps data in memory)
    try {
      buyerProfilesController = Get.find<BuyerProfilesController>(tag: 'buyer_profiles');
    } catch (_) {
      buyerProfilesController = Get.put(
        BuyerProfilesController(apiClient: apiClient),
        tag: 'buyer_profiles',
        permanent: false,
      );
    }
    
    // Fetch buyer profiles after screen is built - show cached data immediately if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If we have cached data, show it immediately and refresh in background
      if (buyerProfilesController.buyerProfilesList.isNotEmpty) {
        // Data already exists, refresh in background
        buyerProfilesController.fetchBuyerProfiles(isReload: true, showCachedData: true);
      } else {
        // No cached data, fetch normally
        buyerProfilesController.fetchBuyerProfiles(isReload: true, showCachedData: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        title: "Buyer Profiles",
      ),
      body: Obx(() {
        // Only show full loading if we have no cached data
        if (buyerProfilesController.isLoading.value && buyerProfilesController.buyerProfilesList.isEmpty) {
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
                  'Loading buyer profiles...',
                  style: sansReg.copyWith(
                    color: AppColor.primaryColor,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                // Search and Filter Section
                Container(
                  margin: EdgeInsets.all(16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColor.ghostWhite,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Buyers',
                    style: sansSemiBold.copyWith(
                      fontSize: 18.sp,
                      color: AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  // Search Input
                  CustomTextFieldWidget(
                    controller: buyerProfilesController.searchController,
                    hintText: 'Search by name, email, or interests...',
                    prefixIcon: Icons.search,
                    onChanged: (_) => buyerProfilesController.onSearchChanged(),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // Category Filter - Full Width
                  Obx(() {
                    return CustomDropDawnBtn(
                      title: buyerProfilesController.selectedCategory.value,
                      items: buyerProfilesController.availableCategories
                          .asMap()
                          .entries
                          .map((entry) => DropdownItem<int>(
                                value: entry.key,
                                child: Padding(
                                  padding: EdgeInsets.all(8.w),
                                  child: Text(
                                    entry.value,
                                    style: sansMedium.copyWith(
                                      fontSize: 14.sp,
                                      color: AppColor.textColor,
                                      height: 1.4.h,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                      onChange: (int? value, int index) {
                        if (value != null) {
                          final category = buyerProfilesController
                              .availableCategories[value];
                          buyerProfilesController.setCategory(category);
                        }
                      },
                      textStyle: sansMedium.copyWith(
                        fontSize: 14.sp,
                        color: AppColor.textColor,
                        height: 1.4.h,
                      ),
                      textPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                      dropdownStyleWidth: false,
                    );
                  }),
                  
                  SizedBox(height: 12.h),
                  
                  // Search and Clear Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Search',
                          onPressed: () {
                            buyerProfilesController.onSearchChanged();
                          },
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomButton(
                          text: 'Clear',
                          color: AppColor.white,
                          borderColor: AppColor.coolGray21,
                          textStyle: sansMedium.copyWith(
                            color: AppColor.coolGray21,
                            fontSize: 14.sp,
                          ),
                          onPressed: () {
                            buyerProfilesController.clearFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  // Results count
                  Obx(() {
                    final total = buyerProfilesController.buyerProfilesList.length;
                    final filtered = buyerProfilesController.filteredProfilesList.length;
                    return Text(
                      filtered == total
                          ? 'Showing all $total buyer profiles'
                          : 'Showing $filtered of $total buyer profiles',
                      style: sansReg.copyWith(
                        fontSize: 12.sp,
                        color: AppColor.coolGray21,
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            // Buyer Profiles Grid
            Expanded(
              child: Obx(() {
                final profiles = buyerProfilesController.filteredProfilesList;
                
                if (profiles.isEmpty && !buyerProfilesController.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search_outlined,
                          size: 80.w,
                          color: AppColor.coolGray21,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          buyerProfilesController.buyerProfilesList.isEmpty
                              ? 'No Buyer Profiles Found'
                              : 'No Matching Profiles',
                          style: sansSemiBold.copyWith(
                            color: AppColor.primaryColor,
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          buyerProfilesController.buyerProfilesList.isEmpty
                              ? 'There are no buyer profiles available at the moment.'
                              : 'Try adjusting your search criteria or filters.',
                          style: sansReg.copyWith(
                            color: AppColor.coolGray21,
                            fontSize: 14.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (buyerProfilesController.buyerProfilesList.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          CustomButton(
                            text: 'Clear Filters',
                            width: 150.w,
                            onPressed: () {
                              buyerProfilesController.clearFilters();
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                }
                
                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 16.w,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    return _buildBuyerProfileCard(profiles[index]);
                  },
                );
              }),
            ),
              ],
            ),
            // Subtle loading indicator when refreshing cached data
            if (buyerProfilesController.isLoading.value && buyerProfilesController.buyerProfilesList.isNotEmpty)
              Positioned(
                top: 8.h,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColor.buttonColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildBuyerProfileCard(BuyerProfile profile) {
    final user = profile.user;
    final username = user?.profile?.username ?? user?.name ?? 'Buyer';
    final email = user?.email ?? '';
    final avatar = user?.profile?.avatar;
    final initials = username.isNotEmpty
        ? username.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : 'U';
    
    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                // Avatar with status badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.buttonColor.withOpacity(0.1),
                      ),
                      child: avatar != null && avatar.isNotEmpty
                          ? ClipOval(
                              child: ImageLoader(
                                url: '${Constant.imageBaseUrl}$avatar',
                                width: 48.w,
                                height: 48.w,
                                boxFit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                initials,
                                style: sansSemiBold.copyWith(
                                  fontSize: 16.sp,
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
                          size: 12.0,
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: sansSemiBold.copyWith(
                          fontSize: 16.sp,
                          color: AppColor.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Buyer',
                        style: sansReg.copyWith(
                          fontSize: 12.sp,
                          color: AppColor.coolGray21,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Categories
            if (profile.categories != null && profile.categories!.isNotEmpty) ...[
              Text(
                'Interested in:',
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
                  ...profile.categories!.take(3).map((category) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColor.buttonColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          category,
                          style: sansReg.copyWith(
                            fontSize: 10.sp,
                            color: AppColor.buttonColor,
                          ),
                        ),
                      )),
                  if (profile.categories!.length > 3)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColor.ghostWhite,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '+${profile.categories!.length - 3} more',
                        style: sansReg.copyWith(
                          fontSize: 10.sp,
                          color: AppColor.coolGray21,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
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
              SizedBox(height: 12.h),
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
                  ...profile.buyerTags!.take(2).map((tag) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColor.buttonColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          tag.tagName ?? '',
                          style: sansReg.copyWith(
                            fontSize: 10.sp,
                            color: AppColor.buttonColor,
                          ),
                        ),
                      )),
                  if (profile.buyerTags!.length > 2)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColor.ghostWhite,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '+${profile.buyerTags!.length - 2} more',
                        style: sansReg.copyWith(
                          fontSize: 10.sp,
                          color: AppColor.coolGray21,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
            ],
            
            Spacer(),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'View Profile',
                    height: 40.h,
                    onPressed: () {
                      FadeScreenTransition(
                        routeName: Routes.buyerProfileDetailRoute,
                        arguments: {'profileId': profile.id},
                      ).navigate();
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomButton(
                    text: 'Contact',
                    height: 40.h,
                    color: AppColor.buttonColor,
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
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controller/buyer_profile_controller.dart';
import '../../model/buyer_profile_model.dart';
import '../../routes/app_routes.dart';
import '../../service/api/api_client.dart';
import '../../transition/fade_transition.dart';
import '../../utils/app_color.dart';
import '../../utils/app_fonts.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_text_field_widget.dart';
import '../../widget/custom_snackbar_widget.dart';

class CreateEditBuyerProfileScreen extends StatefulWidget {
  final bool isEditMode;
  
  const CreateEditBuyerProfileScreen({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<CreateEditBuyerProfileScreen> createState() => _CreateEditBuyerProfileScreenState();
}

class _CreateEditBuyerProfileScreenState extends State<CreateEditBuyerProfileScreen> {
  late BuyerProfileController buyerProfileController;
  
  final TextEditingController preferencesController = TextEditingController();
  final TextEditingController budgetMinController = TextEditingController();
  final TextEditingController budgetMaxController = TextEditingController();
  final TextEditingController profileLinkController = TextEditingController();
  final TextEditingController newCategoryController = TextEditingController();
  
  final TextEditingController tagNameController = TextEditingController();
  String selectedTagType = '';
  String selectedCardCondition = '';
  final TextEditingController purchaseVolumeController = TextEditingController();
  String selectedBudgetTier = '';

  var selectedCategories = <String>[].obs;
  var tags = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  final List<String> availableCategories = [
    "Sports Cards",
    "Trading Cards",
    "Collectible Cards",
    "Baseball Cards",
    "Football Cards",
    "Basketball Cards",
    "Hockey Cards",
    "Soccer Cards",
    "Rookie Cards",
    "Vintage Cards",
    "Modern Cards",
    "Autographed Cards",
    "Graded Cards"
  ];

  final List<String> tagTypes = [
    "condition",
    "rarity",
    "era",
    "player",
    "team",
    "sport"
  ];

  final List<String> cardConditions = [
    "PSA 10",
    "PSA 9",
    "PSA 8",
    "PSA 7",
    "BGS 10",
    "BGS 9.5",
    "BGS 9",
    "Raw"
  ];

  final List<String> budgetTiers = [
    "low",
    "medium",
    "high",
    "premium"
  ];

  @override
  void initState() {
    super.initState();
    final apiClient = Get.find<ApiClient>();
    buyerProfileController = Get.put(
      BuyerProfileController(apiClient: apiClient),
      tag: 'create_edit_buyer_profile',
    );
    
    if (widget.isEditMode) {
      _loadExistingProfile();
    }
  }

  Future<void> _loadExistingProfile() async {
    await buyerProfileController.fetchBuyerProfile();
    final profile = buyerProfileController.buyerProfile.value;
    if (profile != null) {
      selectedCategories.value = profile.categories ?? [];
      tags.value = (profile.buyerTags ?? []).map((tag) => {
        'tag_name': tag.tagName ?? '',
        'tag_type': tag.tagType ?? '',
        'card_condition': tag.cardCondition ?? '',
        'purchase_volume': tag.purchaseVolume?.toString() ?? '',
        'budget_tier': tag.budgetTier ?? '',
      }).toList();
      preferencesController.text = profile.preferences ?? '';
      budgetMinController.text = profile.budgetMin?.toString() ?? '';
      budgetMaxController.text = profile.budgetMax?.toString() ?? '';
      profileLinkController.text = profile.profileLink ?? '';
    }
  }

  @override
  void dispose() {
    Get.delete<BuyerProfileController>(tag: 'create_edit_buyer_profile');
    preferencesController.dispose();
    budgetMinController.dispose();
    budgetMaxController.dispose();
    profileLinkController.dispose();
    newCategoryController.dispose();
    tagNameController.dispose();
    purchaseVolumeController.dispose();
    super.dispose();
  }

  void _addCategory(String category) {
    if (category.trim().isNotEmpty && !selectedCategories.contains(category.trim())) {
      selectedCategories.add(category.trim());
      newCategoryController.clear();
    }
  }

  void _removeCategory(String category) {
    selectedCategories.remove(category);
  }

  void _addTag() {
    if (tagNameController.text.trim().isNotEmpty) {
      final tag = {
        'tag_name': tagNameController.text.trim(),
        'tag_type': selectedTagType,
        'card_condition': selectedCardCondition,
        'purchase_volume': purchaseVolumeController.text.trim(),
        'budget_tier': selectedBudgetTier,
      };
      tags.add(tag);
      
      // Reset tag form
      tagNameController.clear();
      selectedTagType = '';
      selectedCardCondition = '';
      purchaseVolumeController.clear();
      selectedBudgetTier = '';
      setState(() {});
    } else {
      showCustomSnackBar('Tag name is required');
    }
  }

  void _removeTag(int index) {
    tags.removeAt(index);
  }

  Future<void> _submitForm() async {
    if (selectedCategories.isEmpty) {
      showCustomSnackBar('Please add at least one category');
      return;
    }

    isLoading.value = true;
    
    try {
      final tagsToSend = tags.map((tag) {
        final tagData = <String, dynamic>{
          'tag_name': tag['tag_name'],
        };
        if (tag['tag_type'] != null && tag['tag_type'].toString().isNotEmpty) {
          tagData['tag_type'] = tag['tag_type'];
        }
        if (tag['card_condition'] != null && tag['card_condition'].toString().isNotEmpty) {
          tagData['card_condition'] = tag['card_condition'];
        }
        if (tag['purchase_volume'] != null && tag['purchase_volume'].toString().isNotEmpty) {
          tagData['purchase_volume'] = int.tryParse(tag['purchase_volume'].toString());
        }
        if (tag['budget_tier'] != null && tag['budget_tier'].toString().isNotEmpty) {
          tagData['budget_tier'] = tag['budget_tier'];
        }
        return tagData;
      }).toList();

      final success = widget.isEditMode
          ? await buyerProfileController.updateBuyerProfile(
              categories: selectedCategories.toList(),
              tags: tagsToSend,
              preferences: preferencesController.text.trim().isEmpty ? null : preferencesController.text.trim(),
              budgetMin: budgetMinController.text.trim().isEmpty ? null : double.tryParse(budgetMinController.text.trim()),
              budgetMax: budgetMaxController.text.trim().isEmpty ? null : double.tryParse(budgetMaxController.text.trim()),
              profileLink: profileLinkController.text.trim().isEmpty ? null : profileLinkController.text.trim(),
            )
          : await buyerProfileController.createBuyerProfile(
              categories: selectedCategories.toList(),
              tags: tagsToSend,
              preferences: preferencesController.text.trim().isEmpty ? null : preferencesController.text.trim(),
              budgetMin: budgetMinController.text.trim().isEmpty ? null : double.tryParse(budgetMinController.text.trim()),
              budgetMax: budgetMaxController.text.trim().isEmpty ? null : double.tryParse(budgetMaxController.text.trim()),
              profileLink: profileLinkController.text.trim().isEmpty ? null : profileLinkController.text.trim(),
            );

      if (success) {
        // Close the form screen first
        Get.back();
        
        // Refresh buyer profile screen
        try {
          final buyerProfileControllerMain = Get.find<BuyerProfileController>(tag: 'buyer_profile');
          buyerProfileControllerMain.fetchBuyerProfile();
        } catch (_) {}
        
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
              widget.isEditMode 
                  ? 'Buyer profile updated successfully!'
                  : 'Buyer profile created successfully!',
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
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        title: widget.isEditMode ? 'Edit Buyer Profile' : 'Create Buyer Profile',
        onTapBack: () => Get.back(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            
            // Categories Section
            _buildCategoriesSection(),
            
            SizedBox(height: 24.h),
            
            // Tags Section
            _buildTagsSection(),
            
            SizedBox(height: 24.h),
            
            // Preferences Section
            _buildPreferencesSection(),
            
            SizedBox(height: 24.h),
            
            // Budget Section
            _buildBudgetSection(),
            
            SizedBox(height: 24.h),
            
            // Profile Link Section
            _buildProfileLinkSection(),
            
            SizedBox(height: 32.h),
            
            // Action Buttons
            _buildActionButtons(),
            
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.coolGray17, width: 1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: sansSemiBold.copyWith(
              fontSize: 18.sp,
              color: AppColor.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Add Category Input
          Row(
            children: [
              Expanded(
                child: CustomTextFieldWidget(
                  controller: newCategoryController,
                  hintText: 'Add a category',
                  showTitle: false,
                ),
              ),
              SizedBox(width: 8.w),
              CustomButton(
                text: 'Add',
                height: 40.h,
                width: 80.w,
                onPressed: () => _addCategory(newCategoryController.text),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Predefined Categories
          Text(
            'Or select from popular categories:',
            style: sansReg.copyWith(
              fontSize: 12.sp,
              color: AppColor.coolGray21,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() => Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: availableCategories.map((category) {
              final isSelected = selectedCategories.contains(category);
              return InkWell(
                onTap: isSelected ? null : () => _addCategory(category),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.shade50 : AppColor.coolGray17,
                    border: Border.all(
                      color: isSelected ? Colors.green.shade300 : AppColor.coolGray19,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    category,
                    style: sansReg.copyWith(
                      fontSize: 12.sp,
                      color: isSelected ? Colors.green.shade700 : AppColor.primaryColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
          
          // Selected Categories
          Obx(() {
            if (selectedCategories.isEmpty) return SizedBox.shrink();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Text(
                  'Selected categories:',
                  style: sansReg.copyWith(
                    fontSize: 12.sp,
                    color: AppColor.coolGray21,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: selectedCategories.map((category) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade300, width: 1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category,
                            style: sansReg.copyWith(
                              fontSize: 12.sp,
                              color: Colors.green.shade700,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          InkWell(
                            onTap: () => _removeCategory(category),
                            child: Icon(
                              Icons.close,
                              size: 16.w,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.coolGray17, width: 1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Tags',
                style: sansSemiBold.copyWith(
                  fontSize: 18.sp,
                  color: AppColor.primaryColor,
                ),
              ),
              SizedBox(width: 8.w),
              Obx(() => Text(
                '(${tags.length} tags added)',
                style: sansReg.copyWith(
                  fontSize: 14.sp,
                  color: AppColor.coolGray21,
                ),
              )),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Tag Name and Type
          Row(
            children: [
              Expanded(
                child: CustomTextFieldWidget(
                  controller: tagNameController,
                  hintText: 'Tag Name *',
                  showTitle: false,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.coolGray19, width: 1),
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColor.ghostWhite,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedTagType.isEmpty ? null : selectedTagType,
                      hint: Text(
                        'Tag Type',
                        style: sansReg.copyWith(
                          fontSize: 14.sp,
                          color: AppColor.coolGray21,
                        ),
                      ),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String>(
                          value: '',
                          child: Text(
                            'Select Type',
                            style: sansReg.copyWith(
                              fontSize: 14.sp,
                              color: AppColor.coolGray21,
                            ),
                          ),
                        ),
                        ...tagTypes.map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: sansReg.copyWith(
                              fontSize: 14.sp,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedTagType = value ?? '';
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Card Condition, Purchase Volume, Budget Tier
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.coolGray19, width: 1),
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColor.ghostWhite,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCardCondition.isEmpty ? null : selectedCardCondition,
                      hint: Text(
                        'Card Condition',
                        style: sansReg.copyWith(
                          fontSize: 14.sp,
                          color: AppColor.coolGray21,
                        ),
                      ),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String>(
                          value: '',
                          child: Text(
                            'Select Grade',
                            style: sansReg.copyWith(
                              fontSize: 14.sp,
                              color: AppColor.coolGray21,
                            ),
                          ),
                        ),
                        ...cardConditions.map((condition) => DropdownMenuItem<String>(
                          value: condition,
                          child: Text(
                            condition,
                            style: sansReg.copyWith(
                              fontSize: 14.sp,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCardCondition = value ?? '';
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomTextFieldWidget(
                  controller: purchaseVolumeController,
                  hintText: 'Purchase Volume',
                  showTitle: false,
                  inputType: TextInputType.number,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.coolGray19, width: 1),
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppColor.ghostWhite,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedBudgetTier.isEmpty ? null : selectedBudgetTier,
                      hint: Text(
                        'Budget Tier',
                        style: sansReg.copyWith(
                          fontSize: 14.sp,
                          color: AppColor.coolGray21,
                        ),
                      ),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String>(
                          value: '',
                          child: Text(
                            'Select Tier',
                            style: sansReg.copyWith(
                              fontSize: 14.sp,
                              color: AppColor.coolGray21,
                            ),
                          ),
                        ),
                        ...budgetTiers.map((tier) => DropdownMenuItem<String>(
                          value: tier,
                          child: Text(
                            tier,
                            style: sansReg.copyWith(
                              fontSize: 14.sp,
                              color: AppColor.primaryColor,
                            ),
                          ),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedBudgetTier = value ?? '';
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Add Tag Button
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: 'Add Tag',
              height: 40.h,
              width: 120.w,
              onPressed: _addTag,
            ),
          ),
          
          // Selected Tags
          Obx(() {
            if (tags.isEmpty) return SizedBox.shrink();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Text(
                  'Selected tags:',
                  style: sansReg.copyWith(
                    fontSize: 12.sp,
                    color: AppColor.coolGray21,
                  ),
                ),
                SizedBox(height: 8.h),
                ...tags.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tag = entry.value;
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade200, width: 1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [
                              Text(
                                tag['tag_name'] ?? '',
                                style: sansMedium.copyWith(
                                  fontSize: 14.sp,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              if (tag['tag_type'] != null && tag['tag_type'].toString().isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    tag['tag_type'].toString(),
                                    style: sansReg.copyWith(
                                      fontSize: 10.sp,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              if (tag['card_condition'] != null && tag['card_condition'].toString().isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    tag['card_condition'].toString(),
                                    style: sansReg.copyWith(
                                      fontSize: 10.sp,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              if (tag['purchase_volume'] != null && tag['purchase_volume'].toString().isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade100,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'Vol: ${tag['purchase_volume']}',
                                    style: sansReg.copyWith(
                                      fontSize: 10.sp,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ),
                              if (tag['budget_tier'] != null && tag['budget_tier'].toString().isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    tag['budget_tier'].toString(),
                                    style: sansReg.copyWith(
                                      fontSize: 10.sp,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => _removeTag(index),
                          child: Icon(
                            Icons.close,
                            size: 20.w,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.coolGray17, width: 1),
        borderRadius: BorderRadius.circular(8.r),
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
          SizedBox(height: 12.h),
          CustomTextFieldWidget(
            controller: preferencesController,
            hintText: 'Tell us about your collecting preferences, favorite players, teams, or any specific interests...',
            showTitle: false,
            inputType: TextInputType.multiline,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.coolGray17, width: 1),
        borderRadius: BorderRadius.circular(8.r),
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
          Row(
            children: [
              Expanded(
                child: CustomTextFieldWidget(
                  controller: budgetMinController,
                  hintText: 'Minimum Budget (\$)',
                  showTitle: false,
                  inputType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextFieldWidget(
                  controller: budgetMaxController,
                  hintText: 'Maximum Budget (\$)',
                  showTitle: false,
                  inputType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileLinkSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.coolGray17, width: 1),
        borderRadius: BorderRadius.circular(8.r),
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
          SizedBox(height: 12.h),
          CustomTextFieldWidget(
            controller: profileLinkController,
            hintText: 'https://your-profile-link.com (optional)',
            showTitle: false,
            inputType: TextInputType.url,
          ),
          SizedBox(height: 8.h),
          Text(
            'Optional: Link to your social media, website, or other profile',
            style: sansReg.copyWith(
              fontSize: 12.sp,
              color: AppColor.coolGray21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Cancel',
            height: 40.h,
            color: AppColor.white,
            borderColor: AppColor.coolGray21,
            textStyle: sansMedium.copyWith(
              color: AppColor.coolGray21,
              fontSize: 14.sp,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Obx(() => CustomButton(
            text: isLoading.value
                ? (widget.isEditMode ? 'Updating...' : 'Creating...')
                : (widget.isEditMode ? 'Update Profile' : 'Create Profile'),
            height: 40.h,
            isLoading: isLoading.value,
            onPressed: isLoading.value ? null : _submitForm,
          )),
        ),
      ],
    );
  }
}


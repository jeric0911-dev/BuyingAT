import 'package:classified/controller/account_settings_controller.dart';
import 'package:classified/controller/get_country_city_controller.dart';
import 'package:classified/controller/user_data_controller.dart';
import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_fonts.dart';
import 'package:classified/utils/app_image.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/utils/image_loader.dart';
import 'package:classified/widget/custom_app_bar.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:classified/widget/custom_snackbar_widget.dart';
import 'package:classified/widget/custom_text_field_widget.dart';
import 'package:classified/widget/custom_title_bar.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../transition/fade_transition.dart';
import '../../../utils/_constant.dart';
import '../../../widget/custom_drop_dawn_btn.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late AccountSettingsController accountSettingsController;
  late GetCountryCityController getCountryCityController;
  late UserDataController userDataController;
  late Worker _userDataWorker;
  @override
  void initState() {
    super.initState();
    accountSettingsController = Get.find<AccountSettingsController>();
    userDataController = Get.find<UserDataController>();
    getCountryCityController = Get.find<GetCountryCityController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userDataController.fetchUserData();
    });
    _userDataWorker = ever(userDataController.userData, (userData) {
      fetchCityAndCountry(userData.countryId, userData.cityId);
      accountSettingsController.fullName.text = userData.name ?? '';
      accountSettingsController.email.text = userData.email ?? '';
      accountSettingsController.secondaryEmail.text =
          userData.seconderyEmail ?? '';
      accountSettingsController.phoneNumber.text = userData.phone ?? '';
      accountSettingsController.zipCode.text = userData.zipCode ?? '';
      accountSettingsController.countryId.value = userData.countryId ?? 0;
      accountSettingsController.cityId.value = userData.cityId ?? 0;
      accountSettingsController.userImg.value = userData.profileImg ?? '';
    });
  }

  void fetchCityAndCountry(int? countryId, int? cityId) async {
    await getCountryCityController.fetchCountry();
    await getCountryCityController.fetchCity();
    getCountryCityController.filterCountryByCountryId(countryId ?? 0);
    getCountryCityController.filterCityByCityId(cityId ?? 0);
  }

  @override
  void dispose() {
    _userDataWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(title: AppText.accountSettings),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              Row(
                children: [
                  /*Obx(() {
                    return InkWell(
                      onTap: (){
                        accountSettingsController.pickedProfileImage();
                      },
                      child: Stack(
                        children: [
                          (accountSettingsController.userImg.isNotEmpty)
                              ? ClipOval(
                                  child: ImageLoader(
                                    url:
                                        "${Constant.imageBaseUrl}${accountSettingsController.userImg.value}",
                                    height: 130.h,
                                  ),
                                )
                              : ClipOval(
                                  child: Image.asset(
                                    AppImage.icDefaultDp,
                                    height: 130.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: SvgPicture.asset(
                              AppImage.icCamera,
                              height: 36.h,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),*/
                  Obx(() {
                    return InkWell(
                      onTap: () {
                        accountSettingsController.pickedProfileImage();
                      },
                      child: Stack(
                        children: [
                          if (accountSettingsController.pickedImage.value != null)
                            ClipOval(
                              child: Image.file(
                                accountSettingsController.pickedImage.value!,
                                height: 130.h,
                                width: 130.h,
                                fit: BoxFit.cover,
                              ),
                            )
                          else if (accountSettingsController.userImg.isNotEmpty)
                            ClipOval(
                              child: ImageLoader(
                                url: "${Constant.imageBaseUrl}${accountSettingsController.userImg.value.startsWith('/') ? accountSettingsController.userImg.value.substring(1) : accountSettingsController.userImg.value}",
                                height: 130.h,
                                width: 130.h,
                              ),
                            )
                          else
                            ClipOval(
                              child: Image.asset(
                                AppImage.icDefaultDp,
                                height: 130.h,
                                width: 130.h,
                                fit: BoxFit.cover,
                              ),
                            ),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: SvgPicture.asset(
                              AppImage.icCamera,
                              height: 36.h,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  SizedBox(width: 29.w),
                  Expanded(
                    child: Column(
                      children: [
                        CustomButton(
                          height: 56.h,
                          marginRight: 0,
                          marginLeft: 0,
                          onPressed: () {
                            FadeScreenTransition(
                              routeName: Routes.billingAddressRoute,
                            ).navigate();
                          },
                          color: AppColor.lightGreen,
                          borderColor: AppColor.leafGreen2,
                          text: AppText.billingAddress,
                          textStyle: interMedium.copyWith(
                            fontSize: 16.sp,
                            height: 1.4.h,
                            letterSpacing: -.1,
                            color: AppColor.leafGreen3,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        CustomButton(
                          height: 56.h,
                          marginLeft: 0,
                          marginRight: 0,
                          onPressed: () {
                            FadeScreenTransition(
                              routeName: Routes.shippingAddressRoute,
                            ).navigate();
                          },
                          color: AppColor.softPeach,
                          text: AppText.shippingAddress,
                          textStyle: interMedium.copyWith(
                            fontSize: 16.sp,
                            height: 1.4.h,
                            letterSpacing: -.1,
                            color: AppColor.amberOrange4,
                          ),
                          borderColor: AppColor.amberOrange3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              DottedLine(dashColor: AppColor.coolGray13),
              SizedBox(height: 16.h),
              CustomTitleBar(
                title: AppText.orderActivity,
                titleStyle: sansBold.copyWith(
                  fontSize: 18.sp,
                  height: 1.33.h,
                  color: AppColor.primaryColor,
                ),
              ),

              SizedBox(height: 16.h),
              CustomTextFieldWidget(
                controller: accountSettingsController.fullName,
                focusNode: accountSettingsController.fFullName,
                nextFocus: accountSettingsController.fEmail,
                titleText: AppText.fullName,
                hintText: AppText.fullName,
                showTitle: true,
                inputType: TextInputType.text,
              ),

              SizedBox(height: 16.h),
              CustomTextFieldWidget(
                controller: accountSettingsController.email,
                focusNode: accountSettingsController.fEmail,
                nextFocus: accountSettingsController.fPhoneNumber,
                titleText: AppText.email,
                hintText: AppText.demoGmail,
                showTitle: true,
                inputType: TextInputType.emailAddress,
              ),

              SizedBox(height: 16.h),
              CustomTextFieldWidget(
                controller: accountSettingsController.phoneNumber,
                focusNode: accountSettingsController.fPhoneNumber,
                nextFocus: accountSettingsController.fZipCode,
                titleText: AppText.phoneNumber,
                hintText: AppText.phoneNumber,
                showTitle: true,
                inputType: TextInputType.number,
              ),

              SizedBox(height: 16.h),
              CustomTitleBar(title: AppText.countryRegion),
              SizedBox(height: 3.h),
              Obx(() {
                return CustomDropDawnBtn(
                  items: getCountryCityController.countrySelectedList.value,
                  onChange: (int? value, int index) {
                    getCountryCityController.filterCountryByCountryId(value!);
                    getCountryCityController.filterCitiesByCountry(value);
                    accountSettingsController.countryId.value = value;
                    // rechargeController.filterCurrencyByGateway(value!);
                    // rechargeController.getGatewayNameByGateway(value);
                  },
                  title: accountSettingsController.countryName.value.isEmpty
                      ? 'Select Country'
                      : accountSettingsController.countryName.value,
                  btnHeight: 50.h,
                  isSelected:
                      accountSettingsController.countryName.value.isEmpty
                      ? false
                      : true,
                );
              }),

              SizedBox(height: 16.h),
              CustomTitleBar(title: AppText.city),
              SizedBox(height: 3.h),
              Obx(() {
                return CustomDropDawnBtn(
                  items: getCountryCityController.citySelectedList.value,
                  onChange: (int? value, int index) {
                    // getCountryCityController.filterCountryByCountryId(value!);
                    // getCountryCityController.filterCitiesByCountry(value);
                    // accountSettingsController.countryId.value = value;
                    // rechargeController.filterCurrencyByGateway(value!);
                    // rechargeController.getGatewayNameByGateway(value);
                  },
                  title: accountSettingsController.cityName.value.isEmpty
                      ? 'Select Country'
                      : accountSettingsController.cityName.value,
                  btnHeight: 50.h,
                  isSelected: accountSettingsController.cityName.value.isEmpty
                      ? false
                      : true,
                );
              }),

              SizedBox(height: 16.h),
              CustomTextFieldWidget(
                controller: accountSettingsController.zipCode,
                focusNode: accountSettingsController.fZipCode,
                nextFocus: accountSettingsController.fCurrentPassword,
                titleText: AppText.zipCode,
                hintText: AppText.zipCode,
                showTitle: true,
                inputType: TextInputType.number,
              ),

              SizedBox(height: 25.h),
              Obx(() {
                return CustomButton(
                  isLoading: accountSettingsController.isUpdateMeLoading.value,
                  marginLeft: 0,
                  marginRight: 0,
                  text: AppText.saveChanges,
                  onPressed: () {
                    accountSettingsController.updateMe();
                  },
                );
              }),

              SizedBox(height: 32.h),
              DottedLine(dashColor: AppColor.coolGray13),

              SizedBox(height: 25.h),
              CustomTitleBar(
                title: AppText.changePassword,
                titleStyle: sansBold.copyWith(
                  fontSize: 18.sp,
                  height: 1.33.h,
                  color: AppColor.primaryColor,
                ),
              ),

              SizedBox(height: 16.h),
              CustomTextFieldWidget(
                controller: accountSettingsController.currentPassword,
                focusNode: accountSettingsController.fCurrentPassword,
                nextFocus: accountSettingsController.fNewPassword,
                titleText: AppText.currentPassword,
                hintText: AppText.currentPassword,
                showTitle: true,
                isPassword: true,
                inputType: TextInputType.visiblePassword,
              ),

              SizedBox(height: 16.h),
              CustomTextFieldWidget(
                controller: accountSettingsController.newPassword,
                focusNode: accountSettingsController.fNewPassword,
                nextFocus: accountSettingsController.fConfirmPassword,
                titleText: AppText.newPassword,
                hintText: AppText.newPassword,
                showTitle: true,
                isPassword: true,
                inputType: TextInputType.visiblePassword,
              ),

              SizedBox(height: 16.h),
              CustomTextFieldWidget(
                controller: accountSettingsController.confirmPassword,
                focusNode: accountSettingsController.fConfirmPassword,
                titleText: AppText.confirmPassword,
                hintText: AppText.confirmPassword,
                showTitle: true,
                isPassword: true,
                inputType: TextInputType.visiblePassword,
              ),

              SizedBox(height: 25.h),
              Obx(() {
                return CustomButton(
                  isLoading:
                      accountSettingsController.isChangePassLoading.value,
                  borderColor: accountSettingsController.isFormValid.value
                      ? AppColor.buttonColor
                      : Colors.transparent,
                  color: accountSettingsController.isFormValid.value
                      ? AppColor.buttonColor
                      : AppColor.buttonColor.withValues(alpha: .5),
                  marginLeft: 0,
                  marginRight: 0,
                  onPressed: () {
                    accountSettingsController.isFormValid.value
                        ? accountSettingsController.changePassword()
                        : showCustomSnackBar(AppText.pleaseFillAllTheFields);
                  },
                  text: AppText.changePassword,
                );
              }),

              SizedBox(height: 42.h),
            ],
          ),
        ),

        Obx(
          () =>
              (userDataController.isUserDataLoading.value ||
                  getCountryCityController.isLoadingCity.value ||
                  getCountryCityController.isLoadingCountry.value)
              ? CircularProgressIndicator(
                  color: AppColor.buttonColor,
                  strokeWidth: 3,
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}

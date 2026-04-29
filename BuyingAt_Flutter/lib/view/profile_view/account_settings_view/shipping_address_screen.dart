
import 'package:classified/controller/account_settings_controller.dart';
import 'package:classified/controller/get_country_city_controller.dart';
import 'package:classified/controller/user_data_controller.dart';
import 'package:classified/utils/app_color.dart';
import 'package:classified/utils/app_text.dart';
import 'package:classified/widget/custom_app_bar.dart';
import 'package:classified/widget/custom_button.dart';
import 'package:classified/widget/custom_text_field_widget.dart';
import 'package:classified/widget/custom_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../widget/custom_drop_dawn_btn.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  late AccountSettingsController accountSettingsController;
  late GetCountryCityController getCountryCityController;
  late UserDataController userDataController;

  @override
  void initState() {
    super.initState();
    accountSettingsController = Get.find<AccountSettingsController>();
    userDataController = Get.find<UserDataController>();
    getCountryCityController = Get.find<GetCountryCityController>();
    Future.delayed(Duration.zero, () {
      accountSettingsController.fetchShippingData();
    });

    ever(accountSettingsController.shippingData, (shippingData) {
      fetchCityAndCountry(shippingData.countryId, shippingData.cityId);
      accountSettingsController.firstNameShipping.text =
          shippingData.firstName ?? '';
      accountSettingsController.lastNameShipping.text =
          shippingData.lastName ?? '';
      accountSettingsController.addressShipping.text =
          shippingData.address ?? '';
      accountSettingsController.emailShipping.text = shippingData.email ?? '';
      accountSettingsController.countryIdShipping.value =
          shippingData.countryId ?? 0;
      accountSettingsController.cityIdShipping.value = shippingData.cityId ?? 0;
      accountSettingsController.companyNameShipping.text =
          shippingData.companyName ?? '';
      accountSettingsController.phoneNumberShipping.text =
          shippingData.phone ?? '';
      accountSettingsController.zipCodeShipping.text =
          shippingData.zipCode ?? '';
    });
  }

  void fetchCityAndCountry(int? countryIdShipping, int? cityIdShipping) async {
    await getCountryCityController.fetchCountry();
    await getCountryCityController.fetchCity();
    getCountryCityController.filterCountryByCountryIdShipping(
        countryIdShipping ?? 0);
    getCountryCityController.filterCityByCityIdShipping(cityIdShipping ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: AppText.shippingAddress,
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.firstNameBilling,
                focusNode: accountSettingsController.fFirstNameBilling,
                nextFocus: accountSettingsController.fLastNameBilling,
                titleText: AppText.firstName,
                hintText: AppText.firstName,
                showTitle: true,
                inputType: TextInputType.text,
              ),

              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.lastNameBilling,
                focusNode: accountSettingsController.fLastNameBilling,
                nextFocus: accountSettingsController.fCompanyNameBilling,
                titleText: AppText.lastName,
                hintText: AppText.lastName,
                showTitle: true,
                inputType: TextInputType.text,
              ),


              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.companyNameBilling,
                focusNode: accountSettingsController.fCompanyNameBilling,
                nextFocus: accountSettingsController.fEmailShipping,
                titleText: AppText.companyName,
                hintText: AppText.companyName,
                showTitle: true,
                inputType: TextInputType.text,
              ),

              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.emailShipping,
                focusNode: accountSettingsController.fEmailShipping,
                nextFocus: accountSettingsController.fAddressShipping,
                titleText: AppText.email,
                hintText: AppText.demoGmail,
                showTitle: true,
                inputType: TextInputType.emailAddress,
              ),

              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.addressShipping,
                focusNode: accountSettingsController.fAddressShipping,
                nextFocus: accountSettingsController.fPhoneNumberShipping,
                titleText: AppText.address,
                hintText: AppText.address,
                showTitle: true,
                inputType: TextInputType.emailAddress,
              ),

              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.phoneNumberShipping,
                focusNode: accountSettingsController.fPhoneNumberShipping,
                nextFocus: accountSettingsController.fZipCodeShipping,
                titleText: AppText.phoneNumber,
                hintText: AppText.phoneNumber,
                showTitle: true,
                inputType: TextInputType.number,
              ),

              SizedBox(height: 16.h,),
              CustomTitleBar(title: AppText.countryRegion),
              SizedBox(height: 3.h),
              Obx(() {
                return CustomDropDawnBtn(
                  items: getCountryCityController.countrySelectedList.value,
                  onChange: (int? value, int index) {
                    getCountryCityController.filterCountryByCountryIdShipping(
                        value!);
                    getCountryCityController.filterCitiesByCountryShipping(
                        value);
                    accountSettingsController.countryIdShipping.value = value;
                  },
                  title: accountSettingsController.countryNameShipping.value
                      .isEmpty
                      ? 'Select Country'
                      : accountSettingsController.countryNameShipping.value,
                  btnHeight: 50.h,
                  isSelected: accountSettingsController.countryNameShipping
                      .value
                      .isEmpty ? false : true,
                );
              }),


              SizedBox(height: 16.h,),
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
                  title: accountSettingsController.cityNameShipping.value
                      .isEmpty
                      ? 'Select Country'
                      : accountSettingsController.cityNameShipping.value,
                  btnHeight: 50.h,
                  isSelected: accountSettingsController.cityNameShipping.value
                      .isEmpty
                      ? false
                      : true,
                );
              }),

              SizedBox(height: 16.h,),
              CustomTextFieldWidget(
                controller: accountSettingsController.zipCodeShipping,
                focusNode: accountSettingsController.fZipCodeShipping,
                titleText: AppText.zipCode,
                hintText: AppText.zipCode,
                showTitle: true,
                inputType: TextInputType.number,
              ),

              SizedBox(height: 25.h,),
              Obx(() {
                return CustomButton(
                  isLoading: accountSettingsController.isUpdateShippingLoading.value,
                  marginLeft: 0,
                  marginRight: 0,
                  onPressed: (){
                    accountSettingsController.updateShipping();
                  },
                  text: AppText.saveChanges,
                );
              }),

              SizedBox(height: 42.h,),
            ],
          ),
        ),
        Obx(() =>
        (accountSettingsController.isShippingLoading.value)
            ? CircularProgressIndicator(
          color: AppColor.buttonColor,
          strokeWidth: 3,
        )
            : SizedBox.shrink(),
        )

      ],
    );
  }
}

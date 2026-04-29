import 'dart:io';

import 'package:classified/widget/custom_snackbar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../service/api/api_client.dart';
import '../model/user_data_model.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';

class AccountSettingsController extends GetxController {
  ApiClient apiClient;
  AccountSettingsController({required this.apiClient});

  @override
  void onInit() {
    super.onInit();
    setupListeners();
  }

  ///   Order Activity
  final displayName = TextEditingController();
  final userName = TextEditingController();
  final fullName = TextEditingController();
  final email = TextEditingController();
  final secondaryEmail = TextEditingController();
  final phoneNumber = TextEditingController();
  final zipCode = TextEditingController();

  final FocusNode fDisplayName = FocusNode();
  final FocusNode fUserName = FocusNode();
  final FocusNode fFullName = FocusNode();
  final FocusNode fEmail = FocusNode();
  final FocusNode fSecondaryEmail = FocusNode();
  final FocusNode fPhoneNumber = FocusNode();
  final FocusNode fZipCode = FocusNode();

  var countryId = 0.obs;
  var cityId = 0.obs;
  var countryName = ''.obs;
  var cityName = ''.obs;
  var userImg = ''.obs;

  /*final ImagePicker _picker = ImagePicker();

  RxList<File> pickedImagesList = <File>[].obs;

  Future<void> pickedProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    pickedImagesList.add(File(image!.path));
  }*/

  var pickedImage = Rx<File?>(null);

  Future<void> pickedProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
      // No format restriction - supports JPEG, PNG, JFIF, etc.
    );

    if (picked != null) {
      // Check file extension to ensure it's a supported image format
      final extension = picked.path.toLowerCase().split('.').last;
      final supportedFormats = ['jpg', 'jpeg', 'png', 'jfif', 'webp', 'gif'];
      if (supportedFormats.contains(extension)) {
        pickedImage.value = File(picked.path);
      } else {
        showCustomSnackBar("Unsupported image format. Please use JPEG, PNG, or JFIF");
      }
    }
  }

  List<MultipartBody> multipartFiles = [];
  var isUpdateMeLoading = false.obs;
  Future<void> updateMe({bool isReload = false}) async {
    if (isReload) {}
    isUpdateMeLoading.value = true;
    multipartFiles.clear();

    if (pickedImage.value != null) {
      multipartFiles.add(MultipartBody(
        'profile_img',
        pickedImage.value!,
      ));
    }


    var body = {
      'name': fullName.text.trim(),
      'email': email.text.trim(),
      'secondery_email': secondaryEmail.text.trim(),
      'phone': phoneNumber.text.trim(),
      if(countryId.value != 0)'country_id': countryId.value,
      if(cityId.value != 0)'city_id': cityId.value,
      'zip_code': zipCode.text.trim(),
    };

    try {
      http.Response response;

      if (pickedImage.value != null) {
        response = await apiClient.postMultipartData(
          Constant.updateMeUrl,
          body,
          multipartFiles,
        );
      } else {
        response = await apiClient.postData(Constant.updateMeUrl, body);
      }
      if (response.statusCode == 200) {
        showCustomSnackBar("Update successful}", isError: false);
      }
    } catch (e) {
      apiRetryManager.addRequest(() {
        updateMe();
      });
    } finally {
      isUpdateMeLoading.value = false;
    }
  }

  /// Billing Address
  final firstNameBilling = TextEditingController();
  final lastNameBilling = TextEditingController();
  final emailBilling = TextEditingController();
  final companyNameBilling = TextEditingController();
  final phoneNumberBilling = TextEditingController();
  final addressBilling = TextEditingController();
  final zipCodeBilling = TextEditingController();

  final FocusNode fFirstNameBilling = FocusNode();
  final FocusNode fLastNameBilling = FocusNode();
  final FocusNode fEmailBilling = FocusNode();
  final FocusNode fCompanyNameBilling = FocusNode();
  final FocusNode fPhoneNumberBilling = FocusNode();
  final FocusNode fAddressBillingBilling = FocusNode();
  final FocusNode fZipCodeBilling = FocusNode();

  var countryIdBilling = 0.obs;
  var cityIdBilling = 0.obs;
  var countryNameBilling = ''.obs;
  var cityNameBilling = ''.obs;

  // fetch Billing address
  var isBillingLoading = false.obs;
  var billingData = UserData().obs;

  Future<void> fetchBillingData({bool isReload = false}) async {
    if (isReload) {}
    isBillingLoading.value = true;
    try {
      http.Response? response = await apiClient.getData(
        Constant.fetchBillingUrl,
      );
      if (response.statusCode == 200) {
        UserdataModel userdataModel = userdataModelFromJson(response.body);
        billingData.value = userdataModel.data ?? UserData();
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchBillingData();
      });
    } finally {
      isBillingLoading.value = false;
    }
  }

  // Update billing address
  var isUpdateBillingLoading = false.obs;
  Future<void> updateBilling({bool isReload = false}) async {
    if (isReload) {}
    isUpdateBillingLoading.value = true;
    var body = {
      'first_name': firstNameBilling.text.trim(),
      'last_name': lastNameBilling.text.trim(),
      'company_name': companyNameBilling.text.trim(),
      'address': addressBilling.text.trim(),
      'country_id': countryIdBilling.value,
      'city_id': cityIdBilling.value,
      'zip_code': zipCodeBilling.text.trim(),
      'email': emailBilling.text.trim(),
      'phone': phoneNumberBilling.text.trim(),
    };

    try {
      http.Response response = await apiClient.postData(
        Constant.fetchBillingUrl,
        body,
      );

      if (response.statusCode == 200) {
        showCustomSnackBar("Update successful}", isError: false);
      }
    } catch (e) {
      apiRetryManager.addRequest(() {
        updateBilling();
      });
    } finally {
      isUpdateBillingLoading.value = false;
    }
  }

  ///   Shipping Address
  final firstNameShipping = TextEditingController();
  final lastNameShipping = TextEditingController();
  final companyNameShipping = TextEditingController();
  final addressShipping = TextEditingController();
  final emailShipping = TextEditingController();
  final phoneNumberShipping = TextEditingController();
  final zipCodeShipping = TextEditingController();

  final FocusNode fFirstNameShipping = FocusNode();
  final FocusNode fLastShipping = FocusNode();
  final FocusNode fCompanyNameShipping = FocusNode();
  final FocusNode fEmailShipping = FocusNode();
  final FocusNode fAddressShipping = FocusNode();
  final FocusNode fPhoneNumberShipping = FocusNode();
  final FocusNode fZipCodeShipping = FocusNode();

  var countryIdShipping = 0.obs;
  var cityIdShipping = 0.obs;
  var countryNameShipping = ''.obs;
  var cityNameShipping = ''.obs;

  // fetch Shipping address
  var isShippingLoading = false.obs;
  var shippingData = UserData().obs;

  Future<void> fetchShippingData({bool isReload = false}) async {
    if (isReload) {}
    isShippingLoading.value = true;
    try {
      http.Response? response = await apiClient.getData(
        Constant.fetchShippingUrl,
      );
      if (response.statusCode == 200) {
        UserdataModel userdataModel = userdataModelFromJson(response.body);
        shippingData.value = userdataModel.data ?? UserData();
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        fetchShippingData();
      });
    } finally {
      isShippingLoading.value = false;
    }
  }

  // Update billing address
  var isUpdateShippingLoading = false.obs;
  Future<void> updateShipping({bool isReload = false}) async {
    if (isReload) {}
    isUpdateShippingLoading.value = true;
    var body = {
      'first_name': firstNameShipping.text.trim(),
      'last_name': lastNameShipping.text.trim(),
      'company_name': companyNameShipping.text.trim(),
      'address': addressShipping.text.trim(),
      'country_id': countryIdShipping.value,
      'city_id': cityIdShipping.value,
      'zip_code': zipCodeShipping.text.trim(),
      'email': emailShipping.text.trim(),
      'phone': phoneNumberShipping.text.trim(),
    };

    try {
      http.Response response = await apiClient.postData(
        Constant.fetchShippingUrl,
        body,
      );

      if (response.statusCode == 200) {
        showCustomSnackBar("Update successful}", isError: false);
      }
    } catch (e) {
      apiRetryManager.addRequest(() {
        updateShipping();
      });
    } finally {
      isUpdateShippingLoading.value = false;
    }
  }

  ///   Change Password

  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  final FocusNode fCurrentPassword = FocusNode();
  final FocusNode fNewPassword = FocusNode();
  final FocusNode fConfirmPassword = FocusNode();

  var isChangePassLoading = false.obs;
  var isFormValid = false.obs;
  void setupListeners() {
    currentPassword.addListener(validateForm);
    newPassword.addListener(validateForm);
    confirmPassword.addListener(validateForm);
  }

  void validateForm() {
    isFormValid.value =
        currentPassword.text.isNotEmpty &&
        newPassword.text.isNotEmpty &&
        confirmPassword.text.isNotEmpty;
  }

  Future<void> changePassword({bool isReload = false}) async {
    if (isReload) {}
    isChangePassLoading.value = true;
    var body = {
      'password': newPassword.text.trim(),
      'password_confirm': confirmPassword.text.trim(),
      'current_password': currentPassword.text.trim(),
    };
    try {
      http.Response response = await apiClient.postData(
        Constant.changePasswordUrl,
        body,
      );

      if (response.statusCode == 200) {
        showCustomSnackBar("Update successful}", isError: false);
        newPassword.clear();
        currentPassword.clear();
        confirmPassword.clear();
      } else {
        showCustomSnackBar("Something went wrong}");
      }
    } catch (e) {
      apiRetryManager.addRequest(() {
        changePassword();
      });
    } finally {
      isChangePassLoading.value = false;
    }
  }
}

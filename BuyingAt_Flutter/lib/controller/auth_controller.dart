import 'package:classified/controller/more_page_controller.dart';
import 'package:classified/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../helper/email_checker_helper.dart';
import '../model/login_model.dart';
import '../routes/app_routes.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../transition/fade_transition.dart';
import '../utils/_constant.dart';
import '../utils/session_manager.dart';
import 'dart:async';
import '../widget/custom_snackbar_widget.dart';


class AuthController extends GetxController with GetSingleTickerProviderStateMixin {
  ApiClient apiClient;
  AuthController({required this.apiClient});
  late TabController tabController;
  RxInt tabIndex = 0.obs;


  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      tabIndex.value = tabController.index;
    });

    signInEmail.addListener(_updateSignInFormValid);
    signInPassword.addListener(_updateSignInFormValid);
    signUpName.addListener(_updateSignUpFormValid);
    signUpEmail.addListener(_updateSignUpFormValid);
    signUpPassword.addListener(_updateSignUpFormValid);
    signUpConfirmPassword.addListener(_updateSignUpFormValid);
    sendResetOtpEmail.addListener(_updateSendResetOtpFormValid);
    resetPassword.addListener(_updateRestPasswordFormValid);
    resetConfirmPassword.addListener(_updateRestPasswordFormValid);
    _updateSignInFormValid();
    _updateSignUpFormValid();
    _updateRestPasswordFormValid();
    _updateSendResetOtpFormValid();
    _loadRememberedCredentials();
    otpController.addListener(_updateVerifyOtpFormValid);
    _updateVerifyOtpFormValid();
    super.onInit();
  }



  /// Sign In fields
  final signInEmail = TextEditingController();
  final signInPassword = TextEditingController();
  final FocusNode fSignInEmail = FocusNode();
  final FocusNode fSignInPassword = FocusNode();
  var rememberMe = false.obs;
  var isSignInFormValid = false.obs;

  /// Sign Up fields
  final signUpName = TextEditingController();
  final signUpEmail = TextEditingController();
  final signUpPassword = TextEditingController();
  final signUpConfirmPassword = TextEditingController();
  var agreeTerms = false.obs;
  var isSignUpFormValid = false.obs;

  final FocusNode fSignUpName = FocusNode();
  final FocusNode fSignUpEmail = FocusNode();
  final FocusNode fSignUpPassword = FocusNode();
  final FocusNode fSignUpConfirmPassword = FocusNode();




  void _loadRememberedCredentials() async {
    final email = await SessionManager.getValue(kUserEmail);
    final password = await SessionManager.getValue(kUserPassword);
    if (email != null && password != null) {
      signInEmail.text = email;
      signInPassword.text = password;
      rememberMe.value = true;
    }
  }

  void _updateSignInFormValid() {
    isSignInFormValid.value = signInEmail.text.trim().isNotEmpty
        && signInPassword.text.trim().isNotEmpty
        && !EmailChecker.isNotValid(signInEmail.text);
  }

  void toggleAgreeTerms() {
    agreeTerms.value = !agreeTerms.value;
    _updateSignUpFormValid();
  }

  void _updateSignUpFormValid() {
    final email = signUpEmail.text.trim();
    final password = signUpPassword.text.trim();
    final confirmPassword = signUpConfirmPassword.text.trim();
    final name = signUpName.text.trim();

    isSignUpFormValid.value =
        email.isNotEmpty &&
            password.isNotEmpty &&
            confirmPassword.isNotEmpty &&
            name.isNotEmpty &&
            !EmailChecker.isNotValid(email) &&
            password == confirmPassword &&
            agreeTerms.value;
  }



  void switchTab(int index) {
    tabController.animateTo(index);
    tabIndex.value = index;
  }

  var isLoginLoading = false.obs;
  /// Manual login function
  Future<void> manualLogin({bool isReload = false}) async {
    if (isReload) {}
    var body = {
      'email': signInEmail.text.trim(),
      'password': signInPassword.text,
    };
    isLoginLoading.value = true;
    try {
      http.Response? response = await apiClient.postData(
          Constant.manualLoginUrl,body
      );
      LoginModel loginModel = loginModelFromJson(response.body);
      if (response.statusCode == 200) {
         SessionManager.setValue(kIsLOGIN, true);
         SessionManager.setValue(kToken, loginModel.data?.token);
         apiClient.updateHeader(token: loginModel.data?.token);
         const FadeScreenTransition(
           replace: true,
           routeName: Routes.splashRoute,
         ).navigate();
        if (rememberMe.value) {
          SessionManager.setValue(kUserPassword, signInPassword.text);
        } else {
          SessionManager.removeValue(kUserPassword);
        }
      }else if(response.statusCode == 401 || response.statusCode == 404){
        showCustomSnackBar("Email or password is incorrect");
      }
    } catch (_) {

      apiRetryManager.addRequest(() {manualLogin();});
    } finally {
      isLoginLoading.value = false;
    }
  }


  Future<void> manualSignUp({bool isReload = false}) async {
    if (isReload) {}
    var body = {
      'name': signUpName.text.trim(),
      'email': signUpEmail.text.trim(),
      'password': signUpPassword.text,
      'password_confirm': signUpConfirmPassword.text,
    };
    isLoginLoading.value = true;
    try {
      http.Response? response = await apiClient.postData(
          Constant.manualSignUpUrl,body
      );
      LoginModel loginModel = loginModelFromJson(response.body);
      if (response.statusCode == 200) {
        SessionManager.setValue(kIsLOGIN, true);
        SessionManager.setValue(kToken, loginModel.data?.token);
        apiClient.updateHeader(token: loginModel.data?.token);
        // Redirect to create buyer profile after signup
        const FadeScreenTransition(
          replace: true,
          routeName: Routes.createBuyerProfileRoute,
        ).navigate();
        if (rememberMe.value) {
          SessionManager.setValue(kUserPassword, signInPassword.text);
        } else {
          SessionManager.removeValue(kUserPassword);
        }
      }
      else if(response.statusCode == 401){
        showCustomSnackBar("Email or password is incorrect");
      }
    } catch (_) {

      apiRetryManager.addRequest(() {manualLogin();});
    } finally {
      isLoginLoading.value = false;
    }
  }

  ///  Send reset OTP
  final sendResetOtpEmail = TextEditingController();
  final FocusNode fSendResetOtpEmail = FocusNode();
  var isSendResetOtpFormValid = false.obs;
  var isSendResetOtpLoading = false.obs;
  var isReSendOtpLoading = false.obs;

  void _updateSendResetOtpFormValid() {
    isSendResetOtpFormValid.value = sendResetOtpEmail.text.trim().isNotEmpty
        && !EmailChecker.isNotValid(sendResetOtpEmail.text);
  }

  // OTP Timer
  var otpTimer = 0.obs;
  Timer? _otpCountdownTimer;

  void startOtpTimer() {
    otpTimer.value = 600;
    _otpCountdownTimer?.cancel();
    _otpCountdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (otpTimer.value > 0) {
        otpTimer.value--;
        _updateVerifyOtpFormValid();
      } else {
        timer.cancel();
        _updateVerifyOtpFormValid();
      }
    });
    _updateVerifyOtpFormValid();
  }

  void stopOtpTimer() {
    _otpCountdownTimer?.cancel();
    otpTimer.value = 0;
    _updateVerifyOtpFormValid();
  }


  Future<void> sendResetOtp({bool isReload = false}) async {

    var body = {
      'email': sendResetOtpEmail.text.trim(),
    };
    otpController.clear();
    isSendResetOtpLoading.value = true;
    isReSendOtpLoading.value = true;
    try {
      http.Response? response = await apiClient.postData(
          Constant.sendResetOtpUrl,body
      );
      if (response.statusCode == 200 ) {
        startOtpTimer();
        if (isReload) {
          const FadeScreenTransition(
              routeName: Routes.otpVerifyRoute).navigate();
          isReSendOtpLoading.value = false;
        }else {
          showCustomSnackBar(AppText.otpSentToYourGmail,
              isError: false, duration: 3);
        }

      } else if (response.statusCode == 404) {
        showCustomSnackBar(AppText.userNotFound);
      }
    } catch (_) {
      apiRetryManager.addRequest(() {
        sendResetOtp(isReload: isReload);
      });
    } finally {
      isSendResetOtpLoading.value = false;
      isReSendOtpLoading.value = false;
    }
  }


  /// verify OTP
  final TextEditingController otpController = TextEditingController();
  var isVerifyOtpFormValid = false.obs;
  var isVerifyOtpLoading = false.obs;
  void _updateVerifyOtpFormValid() {
    isVerifyOtpFormValid.value = otpController.text.trim().length == 4 && otpTimer.value > 0;
  }


  Future<void> verifyOtp() async {
    var body = {
      "email" : sendResetOtpEmail.text.trim(),
      'otp': otpController.text.trim(),
    };

    isVerifyOtpLoading.value = true;
    try {
      http.Response? response = await apiClient.postData(
          Constant.verifyOtpUrl,body
      );
      if (response.statusCode == 200 ) {

      }else if(response.statusCode == 400){
        const FadeScreenTransition(
            routeName: Routes.resetPasswordRoute).navigate();
        showCustomSnackBar(AppText.invalidOTP,duration: 3);
      }
    } catch (_) {
      apiRetryManager.addRequest(() {verifyOtp();});
    } finally {
      isVerifyOtpLoading.value = false;
    }
  }


///  reset password
  final TextEditingController resetPassword = TextEditingController();
  final TextEditingController resetConfirmPassword = TextEditingController();
  final FocusNode fResetPassword = FocusNode();
  final FocusNode fResetConfirmPassword = FocusNode();
  var isRestPasswordFormValid = false.obs;
  var isRestPasswordLoading = false.obs;
  var isResetPasswordFormValid = false.obs;
  void _updateRestPasswordFormValid() {
    final pass = resetPassword.text.trim();
    final confirm = resetConfirmPassword.text.trim();
    isResetPasswordFormValid.value = pass.isNotEmpty && confirm.isNotEmpty && pass == confirm && pass.length >= 8;
  }


  Future<void> resetPass() async {
    var body = {
      "email" : sendResetOtpEmail.text.trim(),
      "password" : resetPassword.text.trim(),
      "otp": otpController.text.trim(),
      'password_confirm': resetConfirmPassword.text.trim(),
    };

    isRestPasswordLoading.value = true;
    try {
      http.Response? response = await apiClient.postData(
          Constant.resetPasswordUrl,body
      );
      if (response.statusCode == 200 ) {
        showCustomSnackBar(AppText.passwordResetSuccess, isError: false, duration: 3);
        FadeScreenTransition(
            routeName: Routes.authRoute,replace:true).navigate();

      }else if(response.statusCode == 400){
        showCustomSnackBar(AppText.invalidOTP,  duration: 3);
      }
    } catch (_) {
      apiRetryManager.addRequest(() {resetPass();});
    } finally {
      isRestPasswordLoading.value = false;
    }
  }



  /// google login

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email'],
    forceCodeForRefreshToken: false,
  );


  var googleSignUser = Rx<GoogleSignInAccount?>(null);

  Future<void> signIn() async {
    try {
      await _googleSignIn.signOut();
      googleSignUser.value = await _googleSignIn.signIn();
      if (googleSignUser.value != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleSignUser.value!.authentication;
        googleLogin(googleToken: googleAuth.accessToken.toString());
      }
    } catch (_) {
    }
  }

  var isGoogleLoginLoading = false.obs;
  Future<void> googleLogin({String? googleToken}) async {
    isGoogleLoginLoading.value = true;
    try {
      var body = {
        'name': googleSignUser.value?.displayName ?? '',
        'email': googleSignUser.value?.email ?? '',
        'google_id': googleSignUser.value?.id ?? '',
      };
      http.Response response = await apiClient.postData(Constant.googleLoginUrl, body);

      if (response.statusCode == 200) {
        LoginModel loginModel = loginModelFromJson(response.body);
        SessionManager.setValue(kIsLOGIN, true);
        SessionManager.setValue(kToken, loginModel.data?.token);
        apiClient.updateHeader(token: loginModel.data?.token);
          const FadeScreenTransition(
            replace: true,
            routeName: Routes.splashRoute,
          ).navigate();

      }
    } catch (_) {
    } finally {
      isGoogleLoginLoading.value = false;
    }
  }

  @override
  void onClose() {
    stopOtpTimer();
    tabController.dispose();
    signInEmail.dispose();
    signInPassword.dispose();
    signUpName.dispose();
    signUpEmail.dispose();
    signUpPassword.dispose();
    signUpConfirmPassword.dispose();
    otpController.dispose();
    super.onClose();
  }
} 
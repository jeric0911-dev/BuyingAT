import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../controller/navigation_controller.dart';
import '../routes/app_routes.dart';
import '../service/api/api_client.dart';
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../widget/custom_snackbar_widget.dart';

class UserProfileController extends GetxController {
  ApiClient apiClient;
  UserProfileController({required this.apiClient});

  // Form fields
  final bioController = TextEditingController();
  final FocusNode fBio = FocusNode();
  
  // State variables
  var isLoading = false.obs;
  var avatarFile = Rx<File?>(null);
  var avatarPreview = RxString('');
  var isFormValid = false.obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    bioController.addListener(_updateFormValid);
    _updateFormValid();
  }

  void _updateFormValid() {
    final bio = bioController.text.trim();
    isFormValid.value = bio.isNotEmpty && _validateBio(bio);
  }

  // Validate bio - no URLs, emails, phone numbers, social handles, or contact terms
  bool _validateBio(String bio) {
    if (bio.isEmpty) return false;
    
    // Check for URLs/links
    final urlRegex = RegExp(r'(https?://[^\s]+|www\.[^\s]+|[^\s]+\.[a-z]{2,})', caseSensitive: false);
    if (urlRegex.hasMatch(bio)) return false;
    
    // Check for email addresses
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    if (emailRegex.hasMatch(bio)) return false;
    
    // Check for phone numbers
    final phoneRegex = RegExp(r'(\+?1[-.\s]?)?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})|(\+?[0-9]{1,3}[-.\s]?)?[0-9]{3,4}[-.\s]?[0-9]{3,4}[-.\s]?[0-9]{3,4}');
    if (phoneRegex.hasMatch(bio)) return false;
    
    // Check for social media handles
    final socialRegex = RegExp(r'@[a-zA-Z0-9_]+|#[a-zA-Z0-9_]+');
    if (socialRegex.hasMatch(bio)) return false;
    
    // Check for contact info patterns
    final contactRegex = RegExp(r'(contact|call|text|message|reach|find|follow|connect|dm|direct message)', caseSensitive: false);
    if (contactRegex.hasMatch(bio)) return false;
    
    return true;
  }

  String? validateBio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Bio is required";
    }
    
    if (!_validateBio(value)) {
      return "Bio cannot contain external links, email addresses, phone numbers, social media handles, or contact information";
    }
    
    return null;
  }

  // Generate auto username with format BA####
  String generateUsername() {
    final randomNumber = 1000 + (DateTime.now().millisecondsSinceEpoch % 9000);
    return 'BA$randomNumber';
  }

  // Pick image from gallery (supports JPEG, PNG, JFIF, etc.)
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        // No format restriction - supports JPEG, PNG, JFIF, etc.
      );
      if (image != null) {
        // Check file extension to ensure it's a supported image format
        final extension = image.path.toLowerCase().split('.').last;
        final supportedFormats = ['jpg', 'jpeg', 'png', 'jfif', 'webp', 'gif'];
        if (supportedFormats.contains(extension)) {
          avatarFile.value = File(image.path);
          avatarPreview.value = image.path;
        } else {
          showCustomSnackBar("Unsupported image format. Please use JPEG, PNG, or JFIF");
        }
      }
    } catch (e) {
      showCustomSnackBar("Failed to pick image: ${e.toString()}");
    }
  }

  // Set avatar file
  void setAvatarFile(File? file) {
    avatarFile.value = file;
    if (file != null) {
      avatarPreview.value = file.path;
    } else {
      avatarPreview.value = '';
    }
  }

  // Create or update user profile
  Future<void> createOrUpdateProfile() async {
    final bio = bioController.text.trim();
    
    if (bio.isEmpty) {
      showCustomSnackBar("Bio is required");
      return;
    }
    
    if (!_validateBio(bio)) {
      showCustomSnackBar("Bio cannot contain external links, email addresses, phone numbers, social media handles, or contact information");
      return;
    }

    final username = generateUsername();
    isLoading.value = true;

    try {
      var body = {
        'username': username,
        'bio': bio,
      };

      var multipartBody = <MultipartBody>[];
      
      if (avatarFile.value != null) {
        multipartBody.add(MultipartBody("avatar", avatarFile.value));
      }

      http.Response? response = await apiClient.postMultipartData(
        Constant.userProfileUrl,
        body,
        multipartBody,
      );

      if (response.statusCode == 200) {
        showCustomSnackBar("Buyer profile created successfully!", isError: false);
        // Clear form
        bioController.clear();
        avatarFile.value = null;
        avatarPreview.value = '';
        _updateFormValid();
        // Navigate to profile page
        Get.offAllNamed(Routes.bottomNavRoute);
        try {
          final navController = Get.find<NavigationController>();
          navController.index.value = 3; // Profile tab
        } catch (_) {}
      } else {
        final responseBody = response.body;
        try {
          final json = jsonDecode(responseBody);
          final message = json['message'] ?? 'Failed to create profile';
          showCustomSnackBar(message);
        } catch (_) {
          showCustomSnackBar("Failed to create profile");
        }
      }
    } catch (e) {
      showCustomSnackBar("Something went wrong! Please try again");
      apiRetryManager.addRequest(() {
        createOrUpdateProfile();
      });
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    bioController.dispose();
    fBio.dispose();
    super.onClose();
  }
}


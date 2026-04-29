import 'dart:convert';
import 'dart:io';
import '../service/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../service/api/api_retry_manager.dart';
import '../utils/_constant.dart';
import '../widget/custom_snackbar_widget.dart';
import '../routes/app_routes.dart';
import '../transition/fade_transition.dart';
import '../view/dialog/card_added_dialog.dart';
import 'dashboard_controller.dart';

class AddCardController extends GetxController {
  ApiClient apiClient;
  int? cardId; // For edit mode
  AddCardController({required this.apiClient, this.cardId});

  // Form controllers
  final TextEditingController cardTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // Observables
  var priceType = 'FIRM'.obs; // FIRM or OBO
  var condition = ''.obs; // Mint, Near Mint, Excellent, Very Good, Good, Fair, Poor
  var grade = 'No'.obs; // No or Yes
  var sportType = ''.obs; // Football, Basketball, etc.
  var selectedImages = <File>[].obs;
  var existingImages = <String>[].obs; // For edit mode - existing image URLs
  var isLoading = false.obs;
  var isFormValid = false.obs;
  var isEditMode = false.obs;

  // Focus nodes
  final FocusNode cardTitleFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();
  final FocusNode priceFocus = FocusNode();
  final FocusNode weightFocus = FocusNode();

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  // Sport types list
  final List<String> sportTypes = [
    "Football",
    "Basketball",
    "Baseball",
    "Soccer",
    "Hockey",
    "Tennis",
    "Golf",
    "Boxing",
    "Wrestling",
    "Racing",
    "Olympics",
    "Pokemon",
    "One Piece",
    "Magic",
    "Other"
  ];

  // Conditions list
  final List<String> conditions = [
    "Mint",
    "Near Mint",
    "Excellent",
    "Very Good",
    "Good",
    "Fair",
    "Poor"
  ];

  @override
  void onInit() {
    super.onInit();
    isEditMode.value = cardId != null;
    _setupValidation();
  }

  // Fetch card data for editing
  Future<void> fetchCardForEdit(int id) async {
    isLoading.value = true;
    try {
      http.Response? response = await apiClient.getData('${Constant.sellerInventoryUrl}/$id');
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success' && json['data'] != null) {
          final data = json['data'];
          
          // Populate form fields
          cardTitleController.text = data['card_title'] ?? '';
          descriptionController.text = data['description'] ?? '';
          priceController.text = data['price']?.toString() ?? '';
          weightController.text = data['weight']?.toString() ?? '';
          priceType.value = data['price_type'] ?? 'FIRM';
          condition.value = data['condition'] ?? '';
          grade.value = data['grade'] ?? 'No';
          sportType.value = data['sport_type'] ?? '';
          
          // Handle existing images
          if (data['images'] != null) {
            if (data['images'] is List) {
              existingImages.value = (data['images'] as List).map((e) => e.toString()).toList();
            } else if (data['images'] is String) {
              try {
                final decoded = jsonDecode(data['images']);
                if (decoded is List) {
                  existingImages.value = decoded.map((e) => e.toString()).toList();
                } else {
                  existingImages.value = [data['images']];
                }
              } catch (e) {
                existingImages.value = [data['images']];
              }
            }
          }
          
          _validateForm();
        }
      } else {
        showCustomSnackBar("Failed to load card data");
      }
    } catch (e) {
      showCustomSnackBar("Error loading card data: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void _setupValidation() {
    cardTitleController.addListener(_validateForm);
    priceController.addListener(_validateForm);
    ever(condition, (_) => _validateForm());
    ever(sportType, (_) => _validateForm());
    ever(selectedImages, (_) => _validateForm());
  }

  void _validateForm() {
    final hasTitle = cardTitleController.text.trim().isNotEmpty;
    final hasPrice = priceController.text.trim().isNotEmpty;
    final hasCondition = condition.value.isNotEmpty;
    final hasSportType = sportType.value.isNotEmpty;
    // In edit mode, allow submission if there are existing images OR new images
    final hasImages = isEditMode.value 
        ? (selectedImages.isNotEmpty || existingImages.isNotEmpty)
        : selectedImages.isNotEmpty;

    isFormValid.value = hasTitle && hasPrice && hasCondition && hasSportType && hasImages;
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(limit: 6);
      
      if (images.isNotEmpty) {
        final remaining = 6 - selectedImages.length;
        final toAdd = images.take(remaining).map((x) => File(x.path)).toList();
        selectedImages.addAll(toAdd);
        _validateForm();
      }
    } catch (e) {
      showCustomSnackBar("Failed to pick images");
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      _validateForm();
    }
  }

  Future<void> submitCard() async {
    if (!isFormValid.value) {
      showCustomSnackBar("Please fill all required fields");
      return;
    }

    isLoading.value = true;

    try {
      // Create FormData for multipart request
      var body = {
        'card_title': cardTitleController.text.trim(),
        'description': descriptionController.text.trim(),
        'price': double.parse(priceController.text.trim()),
        'price_type': priceType.value,
        'condition': condition.value,
        'grade': grade.value,
        'sport_type': sportType.value,
      };

      // Add weight if provided
      if (weightController.text.trim().isNotEmpty) {
        body['weight'] = double.parse(weightController.text.trim());
      }

      // Prepare multipart files for images
      List<MultipartBody> multipartFiles = [];
      for (int i = 0; i < selectedImages.length; i++) {
        multipartFiles.add(MultipartBody('images[$i]', selectedImages[i]));
      }

      http.Response? response;
      
      if (isEditMode.value && cardId != null) {
        // Update existing card
        response = await apiClient.putMultipartData(
          '${Constant.sellerInventoryUrl}/$cardId',
          body,
          multipartFiles,
        );
      } else {
        // Create new card
        response = await apiClient.postMultipartData(
          Constant.sellerInventoryUrl,
          body,
          multipartFiles,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _resetForm();
        if (isEditMode.value) {
          showCustomSnackBar("Card updated successfully!", isError: false);
        } else {
          Get.dialog(barrierDismissible: false, const CardAddedDialog());
        }
        
        // Refresh My Cards page if it exists
        try {
          final dashboardController = Get.find<DashboardController>();
          dashboardController.fetchMyCards(isReload: true);
        } catch (_) {
          // Controller might not be initialized yet
        }
        
        // Navigate back after a short delay
        Future.delayed(Duration(milliseconds: 500), () {
          Get.back();
        });
      } else {
        final responseData = jsonDecode(response.body);
        showCustomSnackBar(responseData['message'] ?? (isEditMode.value ? "Failed to update card" : "Failed to add card"));
      }
    } catch (e) {
      showCustomSnackBar(isEditMode.value ? "Failed to update card. Please try again." : "Failed to add card. Please try again.");
      print("Error ${isEditMode.value ? 'updating' : 'adding'} card: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    cardTitleController.clear();
    descriptionController.clear();
    priceController.clear();
    weightController.clear();
    priceType.value = 'FIRM';
    condition.value = '';
    grade.value = 'No';
    sportType.value = '';
    selectedImages.clear();
    isFormValid.value = false;
  }

  @override
  void onClose() {
    cardTitleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    weightController.dispose();
    cardTitleFocus.dispose();
    descriptionFocus.dispose();
    priceFocus.dispose();
    weightFocus.dispose();
    super.onClose();
  }
}


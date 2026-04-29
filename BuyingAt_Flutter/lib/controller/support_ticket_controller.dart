import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../service/api/api_client.dart';
import '../../../service/api/api_retry_manager.dart';
import '../../utils/_constant.dart';
import '../model/support_ticket_model.dart';
import '../model/view_ticket_msg_model.dart';
import '../routes/app_routes.dart';
import '../widget/custom_dropdown_widget.dart';
import '../widget/custom_snackbar_widget.dart';



class SupportTicketController extends GetxController{
  ApiClient apiClient;
  SupportTicketController({required this.apiClient});


  /// Support Ticket
  var isTicketLoading = false.obs;
  var ticketList = <TicketData>[].obs;
  Future<void> fetchTicket({bool isReload = false}) async {
    if (isReload) {
      ticketList.clear();
    }
    isTicketLoading.value = true;
    try {
      http.Response? response= await apiClient.getData(Constant.ticketsUrl);
      if (response.statusCode == 200) {
        SupportTicketModel supportTicketModel = supportTicketModelFromJson(response.body);
        ticketList.value = supportTicketModel.data ?? [];

      }
    } catch (_) {
      apiRetryManager.addRequest(() {});
    } finally {
      isTicketLoading.value = false;
    }
  }

  /// create support ticket
   List<String> priorityList = ['High', 'Low', 'Medium'];
   List<String> get priorityTypeList => priorityList;
   List<DropdownItem<int>> prioritySelectedList = [];
   var selectedPriority = ''.obs;

// pick file
  var selectedFileName = 'No files Chosen'.obs;
  File? pickedFile;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      pickedFile = File(result.files.single.path!);
      selectedFileName.value = result.files.single.name;
    }
  }

  TextEditingController subjectTicket = TextEditingController();
  TextEditingController messageTicket = TextEditingController();
  TextEditingController replyMsgTicket = TextEditingController();

  final FocusNode fSubjectTicketNode = FocusNode();
  final FocusNode fMessageTicketNode = FocusNode();
  final FocusNode fReplyMsgTicketNode = FocusNode();

  void submitTicket() {
    if (subjectTicket.text.trim().isEmpty) {
      showCustomSnackBar("Subject cannot be empty");
      return;
    }

    if (selectedPriority.value.isEmpty) {
      showCustomSnackBar("Please select a priority");
      return;
    }

    if (messageTicket.text.trim().isEmpty) {
      showCustomSnackBar("Message cannot be empty");
      return;
    }



    createTicket();
  }

  var isCreateTicketLoading = false.obs;
  List<MultipartBody> multipartBody = [];
  Future<void> createTicket({bool isReload = false}) async {

    var body = {
      'subject': subjectTicket.text,
      'priority': selectedPriority.toString(),
      'message': messageTicket.text,
    };

    isCreateTicketLoading.value = true;



    if (pickedFile != null) {
      multipartBody.add(MultipartBody("file[]", pickedFile));
    }
    isCreateTicketLoading.value = true;
    try {
      http.Response? response = await apiClient.postMultipartData(
          Constant.ticketsUrl,body,multipartBody
      );
      if (response.statusCode == 201) {
        //Get.back();
        subjectTicket.clear();
        messageTicket.clear();
        selectedPriority.value = '';
        pickedFile = null;
        multipartBody.clear();
        selectedFileName.value = 'No files Chosen';
        Get.back();
        showCustomSnackBar("Data inserted successfully",isError: false);
        fetchTicket(isReload: true);
      }
    } catch (_) {

      apiRetryManager.addRequest(() {
        createTicket();
      });
    } finally {
      isCreateTicketLoading.value = false;
    }
  }

  /// reply support ticket
  void checkReplayFields(dynamic id, dynamic ticketId , dynamic userId) {

    if (replyMsgTicket.text.trim().isEmpty) {
      showCustomSnackBar("Message cannot be empty");
      return;
    }

    replyTicket( ticketId: ticketId, id: id,userId: userId );
  }
  var isReplyTicketLoading = false.obs;
  Future<void> replyTicket({bool isReload = false, required dynamic id,required dynamic ticketId, dynamic userId}) async {

    var body = {
      'ticket_id':  id,
      'user_id': userId,
      'message': replyMsgTicket.text,
    };

    if (pickedFile != null) {
      multipartBody..clear()..add(MultipartBody("file[]", pickedFile));
    }
    isReplyTicketLoading.value = true;
    try {
      http.Response? response = await apiClient.postMultipartData(
          Constant.replayTicketUrl,body,multipartBody
      );

      if (response.statusCode == 201) {
        //Get.back();
        replyMsgTicket.clear();
        pickedFile = null;
        multipartBody.clear();
        selectedFileName.value = 'No files Chosen';
        showCustomSnackBar("Reply sent successfully",isError: false);
        Get.toNamed(Routes.msgSupportTicketRoute, arguments: {'id': id, 'item': ticketId,});
      }
    } catch (_) {

      apiRetryManager.addRequest(() {
        replyTicket(id: id, ticketId: ticketId, userId: userId);
      });
    } finally {
      isReplyTicketLoading.value = false;
    }
  }


/// delete Support ticket
  Future<void> deleteSupportTicket({required int propertyId,bool isReload = false}) async {
    if (isReload) {}

    try {
      http.Response? response= await apiClient.getData('${Constant.deleteSupportTicket}/$propertyId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          Get.back();
          fetchTicket();
          showCustomSnackBar('${data['message']}',isError: false);

        } else {
          showCustomSnackBar('${data['message']}');
        }
      }
    } catch (_) {
      apiRetryManager.addRequest(() {});
    } finally {


    }
  }

  /// fetch Support MSg
  var isFetchSupportMsgLoading = false.obs;
  var fetchSupportMsgList = <ViewSupportMsg>[].obs;
  Future<void> fetchSupportMsg({bool isReload = false, dynamic id}) async {
    if (isReload) {}
    isFetchSupportMsgLoading.value = true;
    try {
      http.Response? response= await apiClient.getData(
          "${Constant.viewSupportMsgUrl}/$id");
      if (response.statusCode == 200) {
        ViewSupportMsgModel viewSupportMsgModel = viewSupportMsgModelFromJson(response.body);
        fetchSupportMsgList.value = viewSupportMsgModel.data ?? [];

      }
    } catch (_) {
      apiRetryManager.addRequest(() {fetchSupportMsg(id: id);});
    } finally {
      isFetchSupportMsgLoading.value = false;
    }
  }

  /// dawnload and open file
  // Future<void> downloadFile(String url) async {
  //   final status = await Permission.storage.request();
  //   if (!status.isGranted) return;
  //
  //   try {
  //     // Get file data from URL
  //     final response = await http.get(Uri.parse(url));
  //
  //     if (response.statusCode == 200) {
  //       final dir = await getApplicationDocumentsDirectory();
  //       final fileName = url.split('/').last;
  //       final file = File("${dir.path}/$fileName");
  //
  //       // Write bytes to file
  //       await file.writeAsBytes(response.bodyBytes);
  //
  //       // Open the file
  //       await OpenFile.open(file.path);
  //     } else {
  //       log("Failed to download. Status: ${response.statusCode}");
  //     }
  //   } catch (_) {
  //
  //   }
  // }


  @override
  void dispose() {
    super.dispose();
  }
}
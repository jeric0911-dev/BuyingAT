import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_text.dart';
import '../../../widget/custom_dropdown_widget.dart';
import '../../../widget/custom_text_field_widget.dart';
import '../../controller/support_ticket_controller.dart';
import '../../utils/app_color.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_drop_dawn_btn.dart';
import '../../widget/custom_title_bar.dart';

class CreateSupportTicket extends StatefulWidget {

  const CreateSupportTicket({super.key});

  @override
  State<CreateSupportTicket> createState() => _CreateSupportTicketState();
}

class _CreateSupportTicketState extends State<CreateSupportTicket> {
  late SupportTicketController supportTicketController;

  @override
  void initState() {
    super.initState();
    supportTicketController = Get.find<SupportTicketController>();

  }

  @override
  void dispose() {
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    supportTicketController.prioritySelectedList.clear();
    for (
    int index = 0;
    index < supportTicketController.priorityTypeList.length;
    index++
    ) {
      supportTicketController.prioritySelectedList.add(
        DropdownItem<int>(
          value: index,
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(supportTicketController.priorityTypeList[index]),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColor.backGround,
      appBar: CustomAppBar(title: AppText.supportTicket),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            children: [
              CustomTextFieldWidget(
                titleText: AppText.subject,
                hintText: AppText.subject,
                controller: supportTicketController.subjectTicket,
                focusNode: supportTicketController.fSubjectTicketNode,
                nextFocus: supportTicketController.fMessageTicketNode,
                inputType: TextInputType.emailAddress,
                showTitle: true,
              ),
              SizedBox(height: 18.h),


              CustomTitleBar(title: AppText.priority),
              SizedBox(height: 3.h),
              CustomDropDawnBtn(
                items: supportTicketController.prioritySelectedList,
                onChange: (int? value, int index) {
                  supportTicketController.selectedPriority.value =
                  supportTicketController.priorityTypeList[index];
                },
                title: 'Select City',
                btnHeight: 48.h,
                isIndexValue: true,
              ),
              SizedBox(height: 18.h),

              CustomTextFieldWidget(
                titleText: AppText.message,
                hintText:'Write Description',
                focusNode: supportTicketController.fMessageTicketNode,
                maxLines: 8,
                controller: supportTicketController.messageTicket,
                inputType: TextInputType.emailAddress,
               showTitle: true,
              ),
              SizedBox(height: 18.h),


              CustomTitleBar(title: AppText.attachment),
              SizedBox(height: 3.h),
              Container(
                height: 52.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                      color: AppColor.coolGray6, width: 1.15.sp),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.coolGray7.withValues(alpha: .24),
                      blurRadius: 2.3,
                      spreadRadius: 0,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                         supportTicketController.pickFile();
                      },
                      child: Text(
                        AppText.chooseFiles,
                        style: interMedium.copyWith(
                          color: AppColor.buttonColor,
                          fontSize: 16.sp,
                          height: 2.38.h
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      child: VerticalDivider(
                        thickness: 1,
                        color: AppColor.coolGray15,
                      ),
                    ),
                    SizedBox(width: 8),
                    Obx(() {
                      String fileName = supportTicketController.selectedFileName.value;
                      return Flexible(
                        child: Text(
                          fileName,
                          style: interReg.copyWith(
                            color: AppColor.coolGray18,
                            fontSize: 16.sp,
                            height: 2.38.h
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 48.h),


              Obx(() {
                return CustomButton(
                  text: AppText.submit,
                  textStyle: interSemiBold.copyWith(
                    fontSize: 18.sp,
                    color: AppColor.white,
                    height: 1.40.h,
                    letterSpacing: -.1
                  ),
                  color: AppColor.buttonColor,
                  marginLeft: 0,
                  marginRight: 0,
                  isLoading: supportTicketController.isCreateTicketLoading.value,
                  onPressed: () {
                    supportTicketController.submitTicket();
                  },
                );
              }),
              SizedBox(height: 32.h),

            ],
          ),
        ),
      ),
    );
  }


}

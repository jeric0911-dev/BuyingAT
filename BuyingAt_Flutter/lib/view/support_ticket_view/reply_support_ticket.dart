import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_image.dart';
import '../../../utils/app_text.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/custom_button.dart';
import '../../../widget/custom_text_field_widget.dart';
import '../../../widget/custom_title_bar.dart';
import '../../controller/support_ticket_controller.dart';
import '../../model/support_ticket_model.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_color.dart';
import '../../utils/session_manager.dart';

class ReplySupportTicket extends StatefulWidget {
  const ReplySupportTicket({super.key});

  @override
  State<ReplySupportTicket> createState() => _ReplySupportTicketState();
}

class _ReplySupportTicketState extends State<ReplySupportTicket> {
  late SupportTicketController supportTicketController;
  late TicketData ticketData;
  late dynamic userId;

  @override
  void initState() {
    super.initState();
    userId = SessionManager.getValue(kUserId);
    supportTicketController = Get.find<SupportTicketController>();
    ticketData = Get.arguments['item'] ?? 'Support Ticket';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            backgroundColor: AppColor.backGround,
            appBar: CustomAppBar(
              title: ticketData.ticketId,
              appHeight: 80,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(0.h),
                child: Column(
                  children: [
                    SizedBox(height: 6.h,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.toNamed(
                                Routes.msgSupportTicketRoute,
                                arguments: {
                              'item': ticketData.ticketId,
                              'id': ticketData.id,
                            });
                          },
                          child: SvgPicture.asset(
                            AppImage.icMsg, height: 41.w,),
                        ),
                        CustomButton(
                          textStyle: sansMedium.copyWith(
                              fontSize: 16.sp, color: AppColor.primaryColor),
                          text: AppText.closeTicket,
                          height: 32.h,
                          color: AppColor.primaryColor.withValues(alpha: .08),
                          borderWidth: .60.sp,
                          borderColor: AppColor.primaryColor.withValues(
                              alpha: .40),
                          onPressed: () {
                            supportTicketController.deleteSupportTicket(
                                propertyId: ticketData.id!.toInt());
                          },
                          borderRadius: 6,
                          width: 126.w,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),

                  ],
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: ListView(
                children: [
                  CustomTitleBar(title: AppText.message),
                  SizedBox(height: 17.h),
                  CustomTextFieldWidget(
                    titleText: 'Write Description',
                    maxLines: 5,
                    controller: supportTicketController.replyMsgTicket,
                    focusNode: supportTicketController.fReplyMsgTicketNode,
                    inputType: TextInputType.text,
                    isPhone: false,
                  ),
                  SizedBox(height: 24.h),

                  CustomTitleBar(title: AppText.attachment),
                  SizedBox(height: 17.h),
                  Container(
                    height: 56.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                          color: AppColor.dark.withValues(alpha: .10)),
                    ),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                             supportTicketController.pickFile();
                          },
                          child: Text(
                            "Choose files",
                            style: sansMedium.copyWith(
                              color: AppColor.buttonColor,
                              fontSize: 18.sp,
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
                          String fileName = supportTicketController
                              .selectedFileName.value;
                          return Flexible(
                            child: Text(
                              fileName,
                              style: interReg.copyWith(
                                color: AppColor.coolGray18,
                                fontSize: 18.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 80.h),

                  Obx(() {
                    return CustomButton(
                      height: 56.h,
                      text: AppText.reply,
                      textStyle: sansReg.copyWith(
                          fontSize: 20.sp,
                          height: 1.4.h,
                          color: AppColor.ghostWhite),
                      color: AppColor.primaryColor,
                      marginLeft: 0,
                      marginRight: 0,
                      borderRadius: 12.r,
                      isLoading: supportTicketController.isReplyTicketLoading
                          .value,
                      onPressed: () {
                        supportTicketController.checkReplayFields(
                            ticketData.id, ticketData.ticketId, userId);
                      },
                    );
                  }),
                  SizedBox(height: 32.h),
                ],
              ),
            )
        ),
      ],
    );
  }
}

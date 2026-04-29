import 'package:classified/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../helper/date_converter_helper.dart';
import '../../../utils/_constant.dart';
import '../../../utils/app_color.dart';
import '../../../utils/app_text.dart';
import '../../../widget/custom_app_bar.dart';
import '../../../widget/custom_button.dart';
import '../../controller/support_ticket_controller.dart';
import '../../utils/app_image.dart';
import '../../utils/image_loader.dart';
import '../../utils/session_manager.dart';

class MsgSupportTicket extends StatefulWidget {
  const MsgSupportTicket({super.key});

  @override
  State<MsgSupportTicket> createState() => _MsgSupportTicketState();
}

class _MsgSupportTicketState extends State<MsgSupportTicket> {
  late SupportTicketController supportTicketController;
  late dynamic userId;
  late dynamic userProfile;
  late dynamic ticketId;
  late dynamic status;
  late dynamic id;
  @override
  void initState() {
    super.initState();
    userId = SessionManager.getValue(kUserId);
    userProfile = SessionManager.getValue(kUserImage);
    supportTicketController = Get.find<SupportTicketController>();
    ticketId = Get.arguments['item'];
    status = Get.arguments?['status'] ?? 1;
    id = Get.arguments['id'];
    supportTicketController.fetchSupportMsg(id: id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backGround,
      appBar: CustomAppBar(title: ticketId),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Column(
          children: [
            Obx(() {
              if (supportTicketController.isFetchSupportMsgLoading.value) {
                return Column(
                  children: [
                    SizedBox(height: 120.h),
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColor.buttonColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount:
                      supportTicketController.fetchSupportMsgList.length,
                  itemBuilder: (context, index) {
                    final item =
                        supportTicketController.fetchSupportMsgList[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 14.h),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColor.dark.withValues(alpha: .1))
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColor.buttonColor,
                                        width: 3.w,
                                      ),
                                    ),
                                    child:
                                        (item.userId != userId &&
                                                item.user == null)
                                            ? ClipOval(
                                              child: Image.asset(
                                                AppImage.icDefaultDp,
                                                width: 43.w,
                                                height: 43.w,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                            : ClipOval(
                                              child: ImageLoader(
                                                url: "${Constant.imageBaseUrl}$userProfile",
                                                width: 43.w,
                                                height: 43.w,
                                                boxFit: BoxFit.cover,
                                              ),
                                            ),
                                  ),
                                  SizedBox(width: 20.w),
                                  Text(
                                    item.user == null
                                        ? 'Admin'
                                        : item.user!.name.toString(),
                                    style: sansMedium.copyWith(
                                      fontSize: 24.sp,
                                      color: AppColor.primaryColor,
                                      height: 1.66.h,
                                      letterSpacing: .25,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Padding(
                                padding: EdgeInsets.only(left: 3.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatDateToDTMY(
                                        item.createdAt.toString(),
                                      ),
                                      style: sansMedium.copyWith(
                                        fontSize: 16.sp,
                                        height: 1.40.h,
                                        color: AppColor.primaryColor.withValues(alpha: .8),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      item.message.toString(),
                                      style: sansReg.copyWith(
                                        fontSize: 16.sp,
                                        color: AppColor.coolGray4,
                                        height: 2.38.h,
                                      ),
                                    ),
                                    if (item.attachments != null &&
                                        item.attachments!.isNotEmpty) ...[
                                      InkWell(
                                        onTap: () {
                                        //  supportTicketController.downloadFile(item.attachments![0].toString());
                                        },
                                        child: Padding(
                                          padding:  EdgeInsets.only(top: 10.h),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                AppImage.icAttachment,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                "Attachment 1",
                                                style: sansMedium.copyWith(
                                                  fontSize: 18.sp,
                                                  height: 2.11.h,
                                                  color: AppColor.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        if ((index ==
                            supportTicketController.fetchSupportMsgList.length -
                                1 ) && (status != 0)  )
                          Column(
                            children: [
                              SizedBox(height: 80.h,),
                              CustomButton(
                                height: 56.h,
                                text: AppText.reply,
                                color: AppColor.primaryColor,
                                marginLeft: 0,
                                marginRight: 0,
                                borderRadius: 12.r,
                                onPressed: () {
                                  Get.back();
                                },
                              ),
                              SizedBox(height: 50.h,),
                            ],
                          ),
                        // spacing except last
                      ],
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

import 'package:classified/utils/app_fonts.dart';
import 'package:classified/widget/no_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../utils/app_color.dart';
import '../../../utils/app_text.dart';
import '../../../widget/custom_app_bar.dart';
import '../../controller/support_ticket_controller.dart';
import '../../model/support_ticket_model.dart';
import '../../routes/app_routes.dart';
import '../../transition/fade_transition.dart';
import '../../utils/app_image.dart';
import '../../widget/custom_button.dart';
import '../../widget/support_ticket_items.dart';

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({super.key});

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  late SupportTicketController supportTicketController;

  @override
  void initState() {
    super.initState();
    supportTicketController = Get.find<SupportTicketController>();
    supportTicketController.fetchTicket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backGround,
      appBar: CustomAppBar(
        title: AppText.supportTicket,
        appHeight: 96.h,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.h),
          child: Column(
            children: [
              SizedBox(height: 12.h,),
              Align(
                alignment: Alignment.topRight,
                child: CustomButton(
                  leading: SvgPicture.asset(AppImage.icPlusTwo, height: 14.h,),
                  textStyle: sansBold.copyWith(
                      fontSize: 16.sp, height: 1.h, color: AppColor.white),
                  iconTextWidth: 8.w,
                  text: AppText.newTicket,
                  height: 32.h,
                  onPressed: (){
                    FadeScreenTransition(routeName: Routes.createSupportTicketRoute).navigate();
                  },
                  width: 128.w,
                ),
              ),
              SizedBox(height: 6.h,),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        displacement: 80,
        color: Colors.white,
        backgroundColor: AppColor.buttonColor,
        onRefresh: () async {
          supportTicketController.fetchTicket();
        },

        child: Obx(() {
          final isLoading = supportTicketController.isTicketLoading.value;
          final ticketList = supportTicketController.ticketList;

          if (!isLoading && ticketList.isEmpty) {
            return Center(
              child: NoDataWidget(text: 'No Support Ticket'),
            );
          }

          return Skeletonizer(
            enabled: isLoading,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: isLoading ? 4 : ticketList.length,
              itemBuilder: (context, index) {
                final item = isLoading
                    ? TicketData()
                    : ticketList[index];

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLoading
                        ? (index == 4 ? 40 : 0)
                        : ((ticketList.length - 1) == index ? 40 : 0),
                  ),
                  child: SupportTicketItems(ticketData: item),
                );
              },
            ),
          );
        }),

      ),
    );
  }
}

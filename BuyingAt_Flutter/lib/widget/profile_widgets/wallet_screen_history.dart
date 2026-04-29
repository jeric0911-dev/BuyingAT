import 'package:classified/widget/profile_widgets/transection_info_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_color.dart';
import '../../utils/app_text.dart';

class WalletScreenHistory extends StatelessWidget {
  final String transId;
  final String initiated;
  final String amount;
  final String conversion;
  final String status;
  final String convertAmount;

  const WalletScreenHistory({super.key, required this.transId, required this.initiated, required this.amount, required this.conversion, required this.status, required this.convertAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.fromLTRB(24.w,24.h,20.w,24.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.coolGray12,width: 1.2.sp),
        borderRadius: BorderRadius.circular(12.r),
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InfoRow(
              label: AppText.gatewayTransaction,
              value: transId,
            ),
            InfoRow(
              label: AppText.initiated,
              value: initiated,
            ),
            InfoRow(
              label: AppText.amount,
              value: amount,
              showAmountUSD: true,
            ),
            InfoRow(
              label: AppText.conversion,
              value: conversion,
              secondValue: convertAmount,
            ),
            InfoRow(
              label: AppText.status,
              value: status,
              isStatus: true,
            ),
          ],
        )

    );
  }
}


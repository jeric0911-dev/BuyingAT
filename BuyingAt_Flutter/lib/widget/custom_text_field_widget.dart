import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../utils/app_color.dart';
import '../utils/app_fonts.dart';
import '../utils/app_image.dart';
import '../utils/app_text.dart';
import 'code_picker_widget.dart';

class CustomTextFieldWidget extends StatefulWidget {
  final String titleText;
  final String hintText;
  final TextStyle? hintTextStyle;
  final TextStyle? titleTextStyle;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool isPassword;
  final bool isSuffixWidget;
  final Widget? suffixWidget;
  final Function? onChanged;
  final Function? onSubmit;
  final bool isEnabled;
  final int maxLines;
  final TextCapitalization capitalization;
  final Widget? prefixImage;
  final IconData? prefixIcon;
  final double prefixSize;
  final TextAlign textAlign;
  final bool isAmount;
  final bool isNumber;
  final bool showTitle;
  final bool isIsoFixed;
  final bool showBorder;
  final double iconSize;
  final bool divider;
  final bool isPhone;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final bool isRequired;
  final bool showLabelText;
  final bool autofocus;
  final String? labelText;
  final double? levelTextSize;
  final double? enabledBorderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;

  const CustomTextFieldWidget({
    super.key,
    this.titleText = 'Write something...',
    this.hintText = '',
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onSubmit,
    this.onChanged,
    this.prefixImage,
    this.prefixIcon,
    this.capitalization = TextCapitalization.none,
    this.isPassword = false,
    this.prefixSize = 10,
    this.textAlign = TextAlign.start,
    this.isAmount = false,
    this.isNumber = false,
    this.showTitle = false,
    this.showBorder = true,
    this.iconSize = 18,
    this.divider = false,
    this.isPhone = false,
    this.isIsoFixed = false,
    this.countryDialCode,
    this.onCountryChanged,
    this.isRequired = false,
    this.showLabelText = true,
    this.labelText,
    this.levelTextSize,
    this.enabledBorderRadius,
    this.hintTextStyle,
    this.contentPadding,
    this.textStyle,
    this.titleTextStyle,
    this.autofocus = false,
    this.isSuffixWidget = false,
    this.suffixWidget,
  });

  @override
  CustomTextFieldWidgetState createState() => CustomTextFieldWidgetState();
}

class CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  bool _obscureText = true;

  // void onFocusChanged() {
  //   FocusScope.of(context).unfocus();
  //   FocusScope.of(Get.context!).requestFocus(widget.focusNode);
  //   widget.focusNode?.addListener(() {
  //     setState(() {});
  //   });
  // }

  @override
  void initState() {
    super.initState();

    // Add listener only once
    widget.focusNode?.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    // Remove listener to avoid memory leaks
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _toggle() {
    if (!mounted) return;
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void onFocusChanged() {
    FocusScope.of(context).unfocus();
    FocusScope.of(Get.context!).requestFocus(widget.focusNode);

  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.showTitle
            ? Text(widget.titleText, style: widget.titleTextStyle ?? pJakartaMedium.copyWith(fontSize: 14.sp,height: 1.6.h, color: AppColor.coolGray4,letterSpacing: -.2))
            : const SizedBox(),
        SizedBox(height: widget.showTitle ? 3.5.h : 0),

        Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(widget.enabledBorderRadius ?? 4.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.coolGray7.withValues(alpha: .24),
                blurRadius: 2.3,
                spreadRadius: 0,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          child: TextField(
            onTap: onFocusChanged,
            maxLines: widget.maxLines,
            controller: widget.controller,
            focusNode: widget.focusNode,
            textAlign: widget.textAlign,
            cursorHeight: 16.h,
            style: widget.textStyle ?? interMedium.copyWith(
              fontSize: 16.sp,
              color: AppColor.textColor,
              height: 1.4.h,
            ),
            textInputAction: widget.inputAction,
            keyboardType: widget.isAmount ? TextInputType.number : widget.inputType,
            cursorColor: AppColor.primaryColor,
            textCapitalization: widget.capitalization,
            enabled: widget.isEnabled,
            autofocus: widget.autofocus,
            obscureText: widget.isPassword ? _obscureText : false,
            inputFormatters:
                widget.inputType == TextInputType.phone
                    ? <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                    ]
                    : widget.isAmount
                    ? [FilteringTextInputFormatter.allow(RegExp(r'\d'))]
                    : widget.isNumber
                    ? [FilteringTextInputFormatter.allow(RegExp(r'\d'))]
                    : null,
            // inputFormatters: <TextInputFormatter>[
            //   FilteringTextInputFormatter.digitsOnly,
            // ],
            decoration: InputDecoration(
              contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(
                vertical: 15.h,
                horizontal: 16.w,
              ),
              enabledBorder:  OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  widget.enabledBorderRadius ?? 4.r,
                ),


                borderSide: BorderSide(
                  color:  AppColor.coolGray6,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                  color:  AppColor.coolGray6,
                ),
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color:  AppColor.coolGray6,
                ),
              ),
              isDense: true,
              hintText: widget.hintText,
              fillColor: AppColor.white,
              hintStyle:
                  widget.hintTextStyle ??
                  interMedium.copyWith(fontSize: 16.sp, color: AppColor.coolGray5,height: 1.4.h),
              filled: true,
              labelStyle:
                  widget.showLabelText
                      ? interReg.copyWith(
                        fontSize: 14.sp,
                        color: Theme.of(context).hintColor,
                      )
                      : null,
              label: null,

              prefixIcon: widget.isIsoFixed ? SizedBox(
                width: 110.w,
                height: 56.h,
                child: Row(
                  children: [
                   Padding(
                     padding:  EdgeInsets.only(left: 24.w),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text(AppText.register, style: interMedium.copyWith(height: 1.40.h, fontSize: 14.sp),),
                         SizedBox(height: 2.h,),
                          Text("${widget.countryDialCode}", style: interReg.copyWith(height: 1.40.h, fontSize: 18.sp),),
                       ],
                     ),
                   ),
                    SizedBox(width: 15.w,),
                    Container(
                      height: 32.h,
                      width: 1.h,
                      color: AppColor.coolGray5,
                    ),
                  ],
                ),
              ) :
                  widget.isPhone
                      ? SizedBox(
                        width: 110.w,
                        child: Row(
                          children: [
                            Container(
                              width: 105.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5.r),
                                  bottomLeft: Radius.circular(5.r),
                                ),
                              ),
                              margin: const EdgeInsets.only(right: 0),
                              padding: const EdgeInsets.only(left: 5),
                              child: Center(
                                child: CodePickerWidget(
                                  flagWidth: 25,
                                  padding: EdgeInsets.zero,
                                  onChanged: widget.onCountryChanged,
                                  initialSelection: widget.countryDialCode,
                                  favorite: [widget.countryDialCode ?? '+880'],
                                  dialogBackgroundColor:
                                      Colors.white,
                                  textStyle: interReg.copyWith(
                                    fontSize: 18.sp,
                                    height: 1.4.h,
                                    color: AppColor.coolGray5,
                                  ),
                                ),
                              ),
                            ),

                            Container(
                              height: 20.h,
                              width: 1.h,
                              color: AppColor.coolGray5,
                            ),
                          ],
                        ),
                      )
                      : widget.prefixImage != null && widget.prefixIcon == null
                      ? SizedBox(width:0,child: Center(child: widget.prefixImage!))
                      : widget.prefixImage == null && widget.prefixIcon != null
                      ? Icon(
                        widget.prefixIcon,
                        size: widget.iconSize,
                        color:
                            widget.focusNode?.hasFocus == true
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Theme.of(
                                  context,
                                ).hintColor.withValues(alpha: 0.7),
                      )
                      : null,

              
              suffixIcon: widget.isSuffixWidget? widget.suffixWidget : widget.isPassword
                  ? InkWell(
                onTap: _toggle,
                child: SizedBox(
                  width: 40.w,
                  height: 20.w,
                  child: Center(
                    child: SvgPicture.asset(
                      _obscureText ? AppImage.icHide : AppImage.icShow,
                    ),
                  ),
                ),
              )
                  : null,


              suffixIconConstraints: BoxConstraints(
                minHeight: 20.h,
                minWidth: 20.w,),
            ),


            onSubmitted:
                (text) =>
                    widget.nextFocus != null
                        ? FocusScope.of(context).requestFocus(widget.nextFocus)
                        : widget.onSubmit != null
                        ? widget.onSubmit!(text)
                        : null,
            onChanged: widget.onChanged as void Function(String)?,
          ),
        ),

        widget.divider
            ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Divider(),
            )
            : const SizedBox(),
      ],
    );
  }

  // void _toggle() {
  //   setState(() {
  //     _obscureText = !_obscureText;
  //   });
  // }
}

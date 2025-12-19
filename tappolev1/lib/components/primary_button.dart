import 'package:flutter/material.dart';
import 'package:tappolev1/theme/app_styles.dart';
import '../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  final Color? backgroundColor;
  final Color? textColor;
  final BorderSide? border;
  final TextStyle? textStyle;
  final BoxDecoration? boxDecoration;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.border,
    this.textStyle,
    this.boxDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          boxDecoration ??
          BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryOrange.withAlpha(20),
                spreadRadius: 10,
                blurRadius: 30,
                offset: const Offset(0, 0),
              ),
            ],
          ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryOrange,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          side: border ?? BorderSide.none,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style:
              textStyle ??
              lightpTextStyle.copyWith(
                fontSize: 18,
                color: textColor ?? Colors.white,
              ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrimaryOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const PrimaryOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primaryDarkBlue.withAlpha(20),
          width: 0.5,
        ),
      ),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontFamily: 'Archivo',
            color: AppColors.primaryDarkBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

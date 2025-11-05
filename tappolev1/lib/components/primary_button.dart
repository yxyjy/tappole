import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withAlpha(20),
            spreadRadius: 5,
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Archivo',
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

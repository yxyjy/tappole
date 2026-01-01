import 'package:flutter/material.dart';
import 'package:tappolev1/theme/app_styles.dart';
import '../theme/app_colors.dart';

enum SnackbarType { success, error, info, warning }

class StyledSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    required SnackbarType type,
    String? title,
  }) {
    Color backgroundColor = Colors.white;
    Color accentColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success: // Light Green
        accentColor = AppColors.successGreen; // Dark Green
        icon = Icons.check_circle_outline;
        break;
      case SnackbarType.error:
        accentColor = AppColors.errorOrange; // Dark Red
        icon = Icons.error_outline;
        break;
      case SnackbarType.warning:
        accentColor = AppColors.warningOrange; // Dark Orange
        icon = Icons.warning_amber_rounded;
        break;
      case SnackbarType.info:
      default:
        accentColor = AppColors.infoBlue; // Dark Blue
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withAlpha(77)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: accentColor, size: 28),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null)
                          Text(
                            title,
                            style: primarypTextStyle.copyWith(
                              color: accentColor,
                              fontSize: 16,
                            ),
                          ),
                        Text(
                          message,
                          style: primarypTextStyle.copyWith(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

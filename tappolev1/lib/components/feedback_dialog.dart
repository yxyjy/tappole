import 'package:flutter/material.dart';
import '../services/feedback_service.dart';
import '../theme/app_styles.dart';
//import '../theme/app_colors.dart';

class FeedbackDialog extends StatefulWidget {
  final String requestId;

  const FeedbackDialog({super.key, required this.requestId});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final FeedbackService _feedbackService = FeedbackService();
  int? _selectedRating;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_selectedRating == null) return;

    setState(() => _isSubmitting = true);

    try {
      await _feedbackService.submitFeedback(
        requestId: widget.requestId,
        rating: _selectedRating!,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thank you for your feedback!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button (Top Right)
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: Colors.black54),
              ),
            ),

            // Header
            Text(
              "Great job!",
              style: primaryh2TextStyle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              "Hope you had your problem solved - or learned something new!",
              textAlign: TextAlign.center,
              style: primarypTextStyle.copyWith(
                fontSize: 14,
                color: Color(0xFF535763),
              ),
            ),
            const SizedBox(height: 20),

            // Rating Container
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Please rate your experience:",
                    style: primarypTextStyle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFaceIcon(
                        1,
                        Icons.sentiment_dissatisfied_rounded,
                        const Color(0xFFFF5252),
                      ), // Red
                      const SizedBox(width: 10),
                      _buildFaceIcon(
                        2,
                        Icons.sentiment_neutral_rounded,
                        const Color(0xFFFFC107),
                      ), // Amber
                      const SizedBox(width: 10),
                      _buildFaceIcon(
                        3,
                        Icons.sentiment_very_satisfied_rounded,
                        const Color(0xFF4CAF50),
                      ), // Green
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF06638), // Your Orange
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSubmitting || _selectedRating == null
                    ? null
                    : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaceIcon(int ratingValue, IconData icon, Color color) {
    final bool isSelected = _selectedRating == ratingValue;

    return GestureDetector(
      onTap: () => setState(() => _selectedRating = ratingValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(25) : Colors.transparent,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: color, width: 1)
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Icon(
          icon,
          size: 45,
          color: isSelected ? color : Colors.grey.shade300,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tappolev1/components/primary_button.dart';
import 'package:tappolev1/components/styled_snackbar.dart';
import 'package:tappolev1/theme/app_styles.dart';

class ReportUserPage extends StatefulWidget {
  final String reportedUserId;
  // final String reportedUserName;

  const ReportUserPage({
    super.key,
    required this.reportedUserId,
    //required this.reportedUserName,
  });

  @override
  State<ReportUserPage> createState() => _ReportUserPageState();
}

class _ReportUserPageState extends State<ReportUserPage> {
  // Pre-defined reasons to minimize typing for seniors
  final List<String> _reportReasons = [
    "Rude or Aggressive Behavior",
    "Inappropriate Language",
    "Scam or Fraud Attempt",
    "Did not show up / Left early",
    "Other",
  ];

  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      StyledSnackbar.show(
        context: context,
        message: "Please select a reason for the report.",
        type: SnackbarType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;

      await Supabase.instance.client.from('reports').insert({
        'reporter_id': user?.id,
        'reported_user_id': widget.reportedUserId,
        'reason': _selectedReason,
        'description': _detailsController.text,
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Report Submitted"),
            content: const Text(
              "Thank you. Our team will review this report shortly.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text("OK", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        StyledSnackbar.show(
          context: context,
          message: 'Error sending report: $e',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Report User",
          style: primarypTextStyle.copyWith(color: Colors.redAccent),
        ),
        backgroundColor: Colors.red[50],
        foregroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Reporting this User", style: primaryh2TextStyle),
            const SizedBox(height: 10),
            Text("Please select a reason:", style: primarypTextStyle),
            const SizedBox(height: 15),

            ..._reportReasons.map(
              (reason) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: _selectedReason == reason
                        ? Colors.red
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioListTile<String>(
                  title: Text(reason, style: primarypTextStyle),
                  value: reason,
                  groupValue: _selectedReason,
                  activeColor: Colors.red,
                  onChanged: (value) {
                    setState(() => _selectedReason = value);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Optional Details Field
            Text("Additional Details (Optional):", style: primarypTextStyle),
            const SizedBox(height: 10),
            TextField(
              controller: _detailsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintStyle: primarypTextStyle.copyWith(color: Colors.grey),
                hintText: "Tell us more about what happened...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Submit Button
            PrimaryButton(
              backgroundColor: Colors.red[700],
              text: 'Submit Report',
              onPressed: _submitReport,
            ),
            // SizedBox(
            //   width: double.infinity,
            //   height: 55,
            //   child: ElevatedButton(
            //     onPressed: _isLoading ? null : _submitReport,
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.red[700],
            //       foregroundColor: Colors.white,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //     child: _isLoading
            //         ? const CircularProgressIndicator(color: Colors.white)
            //         : const Text(
            //             "Submit Report",
            //             style: TextStyle(
            //               fontSize: 20,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

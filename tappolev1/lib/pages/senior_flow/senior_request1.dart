import 'package:flutter/material.dart';
import 'package:tappolev1/components/primary_button.dart';
import 'package:tappolev1/pages/senior_flow/senior_activity.dart';
import 'package:tappolev1/services/request_service.dart';
import 'package:tappolev1/theme/app_styles.dart'; // Import your service file

class SeniorRequest1Page extends StatefulWidget {
  const SeniorRequest1Page({super.key});
  @override
  _SeniorRequest1PageState createState() => _SeniorRequest1PageState();
}

class _SeniorRequest1PageState extends State<SeniorRequest1Page> {
  // 1. Controllers and State
  final _requestService = RequestService(); // Instantiate the service
  final TextEditingController _contentController = TextEditingController();
  // ignore: prefer_final_fields
  String _requestTitle =
      "Help Request"; // Placeholder or result of speech-to-text
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // 2. Function to handle form submission and service call
  Future<void> _submitRequest() async {
    // Basic validation
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your message or speak your request.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the service method to insert the new request
      await _requestService.createNewRequest(
        title: _requestTitle,
        content: _contentController.text.trim(),
      );

      // Show success message and navigate away
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted successfully!')),
      );
      // Navigate back or to the activity page after submission
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SeniorActivityPage()),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/seniorhomebg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80), // Added top padding
              Text(
                'Hold the button and speak',
                style: primaryh2TextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Text(
                'Tell us - and the volunteers what you need!',
                style: primarypTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Color.fromARGB(255, 255, 125, 82),
                ),
                onPressed: () {
                  // TODO: Implement actual speech-to-text logic here
                },
                child: Image.asset('assets/images/miclogo.png'),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _contentController,
                minLines: 3,
                maxLines: 5,
                decoration: primaryInputDecoration.copyWith(
                  hintText: 'Or type your request here...',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 40),

              PrimaryButton(text: 'Confirm Request', onPressed: _submitRequest),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Back', style: primarypTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

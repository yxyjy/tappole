import 'package:flutter/material.dart';
import 'package:tappolev1/components/primary_button.dart';
import 'package:tappolev1/components/senior_navbar.dart';
import 'package:tappolev1/services/request_service.dart';
import 'package:tappolev1/theme/app_colors.dart';
import 'package:tappolev1/theme/app_styles.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tappolev1/services/transcribe_service.dart';
import 'dart:io';

class SeniorRequest1Page extends StatefulWidget {
  const SeniorRequest1Page({super.key});
  @override
  State<SeniorRequest1Page> createState() => _SeniorRequest1PageState();
}

class _SeniorRequest1PageState extends State<SeniorRequest1Page> {
  //Requesting Service Integration and Controllers
  final _requestService = RequestService();
  final TextEditingController _contentController = TextEditingController();

  // Initialize with a default, but update it later
  String _requestTitle = "Help Request";
  bool _isLoading = false;

  final TranscribeService _transcribeService = TranscribeService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  @override
  void dispose() {
    _contentController.dispose();
    _audioRecorder.dispose(); // Don't forget to dispose the recorder
    super.dispose();
  }

  // Start Recording
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/temp_request.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      }
    } catch (e) {
      print("Error starting record: $e");
    }
  }

  // Stop & Transcribe
  Future<void> _stopAndTranscribe() async {
    if (!_isRecording) return;

    final path = await _audioRecorder.stop();
    setState(() => _isRecording = false);

    if (path != null) {
      _handleTranscription(File(path));
    }
  }

  // Handle Transcription & Title
  Future<void> _handleTranscription(File file) async {
    setState(() => _isLoading = true);

    try {
      final result = await _transcribeService.transcribeAudioFile(file);

      setState(() {
        final mapResult = result as Map<String, dynamic>;
        print("API RESPONSE: $mapResult"); // Check your console for this log

        final newText = mapResult['text'] ?? "";
        final newTitle = mapResult['title'] ?? "";

        final currentText = _contentController.text;
        if (currentText.isEmpty) {
          _contentController.text = newText;
        } else {
          _contentController.text = '$currentText $newText';
        }

        // Update Title (Only if we got one from AI)
        if (newTitle != null && newTitle.isNotEmpty) {
          _requestTitle = newTitle;
          // TODO: fix the ai generated titles (they dont completely work yet)
        }

        // Move cursor to end
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: _contentController.text.length),
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio transcribed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Transcription failed: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitRequest() async {
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
      await _requestService.createNewRequest(
        title: _requestTitle, // This now holds the AI generated title!
        content: _contentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully!')),
        );

        // Use pushReplacement to clear the stack if going home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SeniorNavBar(initialIndex: 0),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
              GestureDetector(
                onLongPressStart: (_) => _startRecording(),
                onLongPressEnd: (_) => _stopAndTranscribe(),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: _isRecording
                        ? AppColors.lighterOrange
                        : AppColors.primaryOrange,
                  ),
                  onPressed: () {},
                  child: Image.asset('assets/images/miclogo.png'),
                ),
              ),
              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _contentController,
                    minLines: 3,
                    maxLines: 5,
                    // Enable typing/editing
                    enabled:
                        !_isLoading, // Disable while processing to prevent conflicts
                    decoration: primaryInputDecoration.copyWith(
                      hintText: 'Or type your request here...',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      suffixIcon: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization:
                        TextCapitalization.sentences, // Good for dictation
                  ),

                  // Optional: Helper text
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0, right: 8.0),
                      child: Text(
                        "Processing audio...",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                ],
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

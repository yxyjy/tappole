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
import 'dart:convert';

class SeniorRequest1Page extends StatefulWidget {
  const SeniorRequest1Page({super.key});
  @override
  State<SeniorRequest1Page> createState() => _SeniorRequest1PageState();
}

class _SeniorRequest1PageState extends State<SeniorRequest1Page> {
  final _requestService = RequestService();
  final TextEditingController _contentController = TextEditingController();

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
      final Map<String, dynamic> result = await _transcribeService
          .transcribeAudioFile(file);

      print("API DATA: $result");

      setState(() {
        final newText = result['text'] ?? "";
        final newTitle = result['title'];

        // 1. Update Content Text
        final currentText = _contentController.text;
        if (currentText.isEmpty) {
          _contentController.text = newText;
        } else {
          _contentController.text = '$currentText $newText';
        }

        // 2. Update Title (AssemblyAI 'headline' summary)
        if (newTitle != null && newTitle.toString().isNotEmpty) {
          _requestTitle = newTitle;
        }

        // 3. Move cursor
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
      print("Transcription Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Transcription failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        title: _requestTitle,
        content: _contentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully!')),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SeniorNavBar(initialIndex: 1),
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
              const SizedBox(height: 100), // Added top padding
              Text(
                'Hold the button and speak',
                style: primaryh2TextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Tell us - and the volunteers what you need!',
                style: primarypTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onLongPressStart: (_) {
                    _startRecording();
                    // Optional: Add Haptic Feedback for better feel
                    // HapticFeedback.mediumImpact();
                  },
                  onLongPressEnd: (_) {
                    _stopAndTranscribe();
                  },
                  // We use AnimatedContainer AS the button, not wrapping it
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 200,
                    ), // Snappy duration
                    curve: Curves.easeOutBack, // Bouncy effect when growing
                    // 1. Dynamic Size: Grows when recording
                    width: 120,
                    height: 120,

                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: _isRecording
                          ? const Color.fromARGB(255, 97, 187, 190)
                          : AppColors.lighterOrange,

                      // 3. The "Glow" Effect (Shadow)
                      boxShadow: [
                        BoxShadow(
                          color: _isRecording
                              ? const Color.fromARGB(
                                  255,
                                  98,
                                  242,
                                  228,
                                ).withAlpha(50)
                              : Colors.transparent,
                          blurRadius: _isRecording ? 30 : 10, // Soft glow
                          spreadRadius: _isRecording ? 10 : 5, // Wide glow
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/miclogo.png',
                      // Optional: Make icon white when active if needed
                      color: _isRecording ? Colors.white : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _contentController,
                    minLines: 3,
                    maxLines: 3,
                    enabled: !_isLoading,
                    decoration: primaryInputDecoration.copyWith(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      hintText: 'Or type your request here...',
                      hintStyle: primarypTextStyle.copyWith(
                        color: const Color.fromARGB(255, 172, 172, 172),
                      ),
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

                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                      child: Text(
                        "Processing audio...",
                        style: primarypTextStyle.copyWith(
                          fontSize: 12,
                          color: const Color.fromARGB(255, 172, 172, 172),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 40),

              PrimaryButton(text: 'Confirm Request', onPressed: _submitRequest),

              const SizedBox(height: 10),

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

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TranscribeService {
  final String _apiKey = '980213d749b34f0a9411e532c6815dc5';

  Future<Map<String, dynamic>> transcribeAudioFile(File audioFile) async {
    try {
      final String uploadUrl = await _uploadFile(audioFile);
      print("🚀 File Uploaded: $uploadUrl");

      final String transcriptId = await _requestTranscription(uploadUrl);
      print("⏳ Transcription Started. ID: $transcriptId");

      return await _pollForCompletion(transcriptId);
    } catch (e) {
      print("Error in AssemblyAI service: $e");
      return {
        'text': "Error: Could not transcribe audio.",
        'title': "Voice Request",
      };
    }
  }

  Future<String> _uploadFile(File file) async {
    final url = Uri.parse('https://api.assemblyai.com/v2/upload');
    final response = await http.post(
      url,
      headers: {'authorization': _apiKey},
      body: await file.readAsBytes(), // Send raw bytes
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['upload_url'];
    } else {
      throw Exception('Upload failed: ${response.body}');
    }
  }

  Future<String> _requestTranscription(String audioUrl) async {
    final url = Uri.parse('https://api.assemblyai.com/v2/transcript');

    final response = await http.post(
      url,
      headers: {'authorization': _apiKey, 'content-type': 'application/json'},
      body: jsonEncode({
        'audio_url': audioUrl,
        // ENABLE AUTO-TITLE FEATURES:
        'summarization': true,
        'summary_model': 'informative',
        'summary_type':
            'headline', // 'headline' gives a short, title-like summary
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['id'];
    } else {
      throw Exception('Start transcription failed: ${response.body}');
    }
  }

  // --- Step C: Wait for Results ---
  Future<Map<String, dynamic>> _pollForCompletion(String transcriptId) async {
    final url = Uri.parse(
      'https://api.assemblyai.com/v2/transcript/$transcriptId',
    );

    while (true) {
      final response = await http.get(url, headers: {'authorization': _apiKey});

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final status = json['status'];

        if (status == 'completed') {
          print("✅ Transcription Complete!");

          // Return the Text AND the generated Summary (Title)
          return {
            'text': json['text'] ?? "",
            // Use the summary as the title. Fallback to 'New Request' if missing.
            'title': json['summary'] ?? "New Request",
          };
        } else if (status == 'error') {
          throw Exception("Transcription failed: ${json['error']}");
        } else {
          // Still processing... wait 2 seconds and check again
          await Future.delayed(const Duration(seconds: 2));
        }
      } else {
        throw Exception("Polling failed: ${response.body}");
      }
    }
  }
}

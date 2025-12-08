import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class TranscribeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> transcribeAudioFile(File file) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
      final storagePath = 'voice_requests/$fileName';

      await _supabase.storage.from('temp_audio').upload(storagePath, file);

      final String secureUrl = await _supabase.storage
          .from('temp_audio')
          .createSignedUrl(storagePath, 300);

      print("Sending this URL to AssemblyAI: $secureUrl"); // Debugging

      // 3. Call Edge Function with the NEW secure URL
      final response = await _supabase.functions.invoke(
        'transcribe-audio',
        body: {'audioUrl': secureUrl}, // <--- NOT publicUrl
      );

      final data = response.data;

      if (data != null && data['text'] != null) {
        return data['text'];
      } else if (data != null && data['error'] != null) {
        throw Exception(data['error']);
      } else {
        throw Exception("Unknown transcription error");
      }
    } catch (e) {
      rethrow;
    }
  }
}

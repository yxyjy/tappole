import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Submits feedback to the database
  Future<void> submitFeedback({
    required String requestId,
    required int rating, // 1 = Sad, 2 = Neutral, 3 = Happy
  }) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final requestData = await _supabase
        .from('requests')
        .select('accepted_by')
        .eq('req_id', requestId)
        .single();

    final String? volunteerId = requestData['accepted_by'];
    if (volunteerId == null) {
      throw Exception(
        "Cannot submit feedback: No volunteer associated with this request.",
      );
    }

    // 2. Insert into feedback table
    await _supabase.from('feedback').insert({
      'provided_by': currentUser.id,
      'provided_to': volunteerId,
      'request': requestId,
      'feedback_rating': rating,
    });
  }

  Future<Map<String, dynamic>?> getFeedbackForRequest(String requestId) async {
    try {
      final data = await _supabase
          .from('feedback')
          .select()
          .eq('request', requestId)
          .maybeSingle(); // Returns null if no row found, instead of crashing
      return data;
    } catch (e) {
      print("Error fetching feedback: $e");
      return null;
    }
  }
}

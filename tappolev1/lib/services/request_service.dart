import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request.dart';

class RequestService {
  final _supabase = Supabase.instance.client;

  /// Fetches the profile for the currently logged-in user
  Future<List<Request>> getRequestsBySenior() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final response = await _supabase
          .from('requests')
          .select()
          .eq('requested_by', user.id);

      // Supabase returns a List<Map<String, dynamic>>
      final List<dynamic> dataList = response as List<dynamic>;

      // Convert the list of maps to a list of Request objects
      return dataList
          .map((map) => Request.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching senior requests: $e');
      throw Exception('Could not fetch senior requests');
    }
  }

  Future<void> createNewRequest({
    required String title,
    required String content,
  }) async {
    // 1. Get the current user's ID
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to create a request.');
    }

    // NOTE: We rely on the database to handle req_id, created_at,
    // and updated_at (using SQL default values or triggers).

    try {
      // 2. Prepare the data payload
      final requestData = {
        // req_id is omitted; rely on DB default (UUID)
        'requested_by': user.id, // Set to the current logged-in user's ID
        'accepted_by': null, // Must be null initially
        'req_title': title,
        'req_content': content,
        'req_status': 'pending', // Set initial status (must match your ENUM)
        // created_at / updated_at are omitted; rely on DB default (now())
      };

      // 3. Execute the insert command
      final response = await _supabase
          .from('requests')
          .insert(requestData)
          .select(); // Use .select() to get the inserted record back (optional)

      // 4. Handle any Supabase-specific errors
      if (response == null || response.isEmpty) {
        throw Exception('Insert failed or no data returned.');
      }

      // Optionally, you can return the newly created Request object:
      // final newRequestMap = response.first as Map<String, dynamic>;
      // return Request.fromMap(newRequestMap);
    } catch (e) {
      print('Error creating new request: $e');
      // Re-throw the error for the UI layer to handle (e.g., show a Snackbar)
      throw Exception('Failed to create request: ${e.toString()}');
    }
  }
}

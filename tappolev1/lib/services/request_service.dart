import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request.dart';

class RequestService {
  final _supabase = Supabase.instance.client;

  //1. Gets all requests made by currently logged in user
  Future<List<Request>> getRequestsBySenior() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final response = await _supabase
          .from('requests')
          .select()
          .eq('requested_by', user.id)
          .order('created_at', ascending: false);

      final List<dynamic> dataList = response as List<dynamic>;
      return dataList
          .map((map) => Request.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching senior requests: $e');
      throw Exception('Could not fetch senior requests');
    }
  }

  //2. Create a new request
  Future<void> createNewRequest({
    String? title,
    required String content,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to create a request.');
    }

    try {
      final requestData = {
        'requested_by': user.id,
        'accepted_by': null,
        'req_title': title ?? 'Help Request',
        'req_content': content,
        'req_status': 'pending',
      };

      final response = await _supabase
          .from('requests')
          .insert(requestData)
          .select();

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

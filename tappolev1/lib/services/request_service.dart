import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request.dart';

class RequestService {
  final _supabase = Supabase.instance.client;

  //gets all requests made by currently logged in user (senior)
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

  //creates a new request (senior)
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
    } catch (e) {
      print('Error creating new request: $e');
      throw Exception('Failed to create request: ${e.toString()}');
    }
  }

  //gets all pending requests to view and accept (volunteer)
  Future<List<Request>> getPendingRequestsForVolunteers() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final response = await _supabase
          .from('requests')
          .select('*, profiles!requests_requested_by_fkey(first_name)')
          .eq('req_status', 'pending')
          .isFilter('accepted_by', null)
          .order('created_at', ascending: false);

      final List<dynamic> dataList = response as List<dynamic>;

      return dataList
          .map((map) => Request.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching volunteer requests: $e');
      throw Exception('Could not fetch volunteer requests');
    }
  }

  //accepts a request and starts a call (volunteer)
  Future<void> acceptRequestAndStartCall(String requestId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final response = await _supabase.functions.invoke(
        'create-call-room',
        body: {'requestId': requestId, 'volunteerId': user.id},
      );

      final data = response.data;

      if (data == null || data['error'] != null) {
        throw Exception(data?['error'] ?? 'Unknown error accepting request');
      }
    } catch (e) {
      print('Error starting call: $e');
      rethrow;
    }
  }

  //gets all requests accepted by currently logged in user (volunteer)
  Future<List<Request>> getRequestsForVolunteer() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final response = await _supabase
          .from('requests')
          .select()
          .eq('accepted_by', user.id)
          .order('created_at', ascending: false);

      final List<dynamic> dataList = response as List<dynamic>;
      return dataList
          .map((map) => Request.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching volunteer requests: $e');
      throw Exception('Could not fetch volunteer requests');
    }
  }

  // Update request content
  Future<void> updateRequestContent(String requestId, String newContent) async {
    try {
      await _supabase
          .from('requests')
          .update({'req_content': newContent})
          .eq('req_id', requestId);
    } catch (e) {
      print('Error updating request: $e');
      throw Exception('Could not update request');
    }
  }
}

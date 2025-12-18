import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/request.dart';

class RequestService {
  final _supabase = Supabase.instance.client;

  //gets all requests made by currently logged in user (senior)
  // Future<List<Request>> getRequestsBySenior({bool isAscending = false, String status = ''}) async {
  //   final user = _supabase.auth.currentUser;
  //   if (user == null) {
  //     throw Exception('User not logged in');
  //   }

  //   try {
  //     final response = await _supabase
  //         .from('requests')
  //         .select()
  //         .eq('requested_by', user.id)
  //         .order('created_at', ascending: isAscending);

  //     final List<dynamic> dataList = response as List<dynamic>;
  //     return dataList
  //         .map((map) => Request.fromMap(map as Map<String, dynamic>))
  //         .toList();
  //   } catch (e) {
  //     print('Error fetching senior requests: $e');
  //     throw Exception('Could not fetch senior requests');
  //   }
  // }
  Future<List<Request>> getRequestsBySenior({
    bool isAscending = false,
    String status = 'All', // Default to 'All' to show everything
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      // 1. Start the query builder
      var query = _supabase
          .from('requests')
          .select()
          .eq('requested_by', user.id);

      // 2. Conditionally apply the status filter
      // Check if status is NOT 'All' and NOT empty
      if (status.isNotEmpty && status != 'All') {
        // We convert to lowercase to match database values ('pending', 'accepted', etc.)
        query = query.eq('req_status', status.toLowerCase());
      }

      // 3. Apply ordering and execute
      final response = await query.order('created_at', ascending: isAscending);

      final List<dynamic> dataList = response as List<dynamic>;
      return dataList
          .map((map) => Request.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching senior requests: $e');
      throw Exception('Could not fetch senior requests');
    }
  }

  //gets stats for senior dashboard
  Future<Map<String, int>> getSeniorStats(String seniorId) async {
    try {
      // 1. Get TOTAL requests (Fetch IDs only to keep it light)
      final totalData = await _supabase
          .from('requests')
          .select('req_id') // Only fetch the ID column
          .eq('requested_by', seniorId);

      final int totalCount = (totalData as List).length;

      // 2. Get ACCEPTED requests
      final acceptedData = await _supabase
          .from('requests')
          .select('req_id')
          .eq('requested_by', seniorId)
          .eq('req_status', 'accepted');

      final int acceptedCount = (acceptedData as List).length;

      return {'total': totalCount, 'accepted': acceptedCount};
    } catch (e) {
      print('Error fetching senior stats: $e');
      return {'total': 0, 'accepted': 0};
    }
  }

  //gets stats for volunteer dashboard
  Future<Map<String, dynamic>> getVolunteerStats(String volunteerId) async {
    try {
      final completedCount = await _supabase
          .from('requests')
          .count(CountOption.exact)
          .eq('accepted_by', volunteerId)
          .eq('req_status', 'accepted');

      final feedbackResponse = await _supabase
          .from('feedback')
          .select('feedback_rating')
          .eq('provided_to', volunteerId);

      final List<dynamic> ratings = feedbackResponse as List<dynamic>;

      double averageRating = 0.0;
      String displayString = "0.0 / 5";

      if (ratings.isNotEmpty) {
        final totalRawScore = ratings.fold<int>(
          0,
          (sum, item) => sum + (item['feedback_rating'] as int),
        );
        final double rawAverage = totalRawScore / ratings.length;
        averageRating = rawAverage / 3 * 5;
        displayString = "${averageRating.toStringAsFixed(1)} / 5";
      }

      return {
        'completed': completedCount,
        'rating': displayString, // Returns a double (e.g., 2.5, 3.0)
        'review_count': ratings.length, // Useful to show "(12 reviews)"
      };
    } catch (e) {
      print('Error fetching volunteer stats: $e');
      return {'completed': 0, 'rating': 0.0, 'review_count': 0};
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
  Future<List<Request>> getPendingRequestsForVolunteers({
    bool isAscending = false,
  }) async {
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
          .order('created_at', ascending: isAscending);

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
  Future<List<Request>> getRequestsForVolunteer({
    bool isAscending = false,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final response = await _supabase
          .from('requests')
          .select()
          .eq('accepted_by', user.id)
          .order('created_at', ascending: isAscending);

      final List<dynamic> dataList = response as List<dynamic>;
      return dataList
          .map((map) => Request.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching volunteer requests: $e');
      throw Exception('Could not fetch volunteer requests');
    }
  }

  // Update request content (senior)
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

  // cancel a request (senior)
  Future<void> cancelRequest(String requestId) async {
    try {
      await _supabase
          .from('requests')
          .update({'req_status': 'cancelled'})
          .eq('req_id', requestId);
    } catch (e) {
      print('Error cancelling request: $e');
      throw Exception('Could not cancel request');
    }
  }
}

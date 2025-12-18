import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../pages/video_call/incoming_call.dart';
import '../components/feedback_dialog.dart';
import '../pages/video_call/video_call_page.dart';

class CallListenerService {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;

  /// Start listening for incoming calls for a specific senior.
  /// Call this in your SeniorNavBar initState.
  void startListening(String seniorId) {
    // 1. Prevent duplicate listeners
    if (_channel != null) return;

    print("🎧 Started listening for calls for Senior: $seniorId");

    _channel = _supabase.channel('public:video_calls');

    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert, // Listen for NEW calls
          schema: 'public',
          table: 'video_calls',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'received_by', // Only listen if I am the receiver
            value: seniorId,
          ),
          callback: (payload) {
            // 2. Trigger the handler with the new data
            print("🔔 Incoming call event received!");
            _handleIncomingCall(payload.newRecord);
          },
        )
        .subscribe();
  }

  Future<void> _handleIncomingCall(Map<String, dynamic> record) async {
    print("📦 RAW SUPABASE DATA: $record");
    // Extract data from the 'video_calls' table insert
    final String? callId = record['request_id'];
    final String? volunteerId = record['initiated_by'];
    final currentUser = _supabase.auth.currentUser;

    if (callId != null &&
        volunteerId != null &&
        currentUser != null &&
        navigatorKey.currentState != null) {
      print("📞 Incoming Call Detected!");

      // 1. Push Ringing Screen & WAIT for user decision (True/False)
      final bool? isAccepted = await navigatorKey.currentState!.push<bool>(
        MaterialPageRoute(
          builder: (_) => IncomingCallPage(
            callId: callId,
            volunteerId: volunteerId,
            currentUserId: currentUser.id,
          ),
        ),
      );

      // 2. Handle Decision
      if (isAccepted == true) {
        print("✅ Call Accepted. Starting Video...");

        // 3. Start Video Call & WAIT for it to end
        await navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => VideoCallPage(
              callId: callId,
              volunteerUserId: currentUser.id,
              volunteerUserName: "Volunteer", // Or fetch real name
              // volunteerId: volunteerId,
              // volunteerName: "Volunteer", // Or fetch real name
            ),
          ),
        );

        // 4. Call Ended -> Show Feedback
        print("🏁 Call finished. Showing Feedback.");
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) =>
                FeedbackDialog(requestId: callId, volunteerId: volunteerId),
          );
        }
      } else {
        print("❌ Call Declined or Dismissed.");
        // Do nothing (No feedback needed)
      }
    } else {
      print("⚠️ Call detected but missing data.");
    }
  }

  Future<void> stopListening() async {
    if (_channel == null) return;

    print("🛑 Safely removing channel...");

    final tempChannel = _channel;

    _channel = null;

    try {
      await _supabase.removeChannel(tempChannel!);
    } catch (e) {
      print("⚠️ Channel already disconnected or error removing: $e");
    }
  }
}

// Global instance
final callListener = CallListenerService();

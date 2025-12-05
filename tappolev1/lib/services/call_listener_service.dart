import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Ensure this exposes your global 'navigatorKey'
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

  /// Handles the navigation logic when a call is detected
  void _handleIncomingCall(Map<String, dynamic> record) {
    // In our Zego setup, the 'request_id' acts as the unique Room/Call ID
    final String? callId = record['request_id'];
    final currentUser = _supabase.auth.currentUser;

    if (callId != null && currentUser != null) {
      print("📞 Starting Call UI. Call ID: $callId");

      // 3. Use global navigator key to push the page
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => VideoCallPage(
            callId: callId,
            userId: currentUser.id,
            // Try to get the real name from metadata, fallback to 'Senior'
            userName: currentUser.userMetadata?['first_name'] ?? 'Senior',
          ),
        ),
      );
    } else {
      print("⚠️ Call detected but missing callId or User session.");
    }
  }

  /// Stop listening (Call this on Logout)
  void stopListening() {
    if (_channel != null) {
      print("🛑 Stopped listening for calls.");
      _supabase.removeChannel(_channel!);
      _channel = null;
    }
  }
}

// Global instance
final callListener = CallListenerService();

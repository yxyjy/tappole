import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Import your navigatorKey
import '../pages/video_call/video_call_page.dart'; // Import your video page

class CallListenerService {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;

  // Start listening for calls for a specific senior
  void startListening(String seniorId) {
    // Prevent duplicate listeners
    if (_channel != null) return;

    print("🎧 Started listening for calls for Senior: $seniorId");

    _channel = _supabase.channel('public:video_calls');

    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent
              .insert, // 1. Typed Enum instead of string 'INSERT'
          schema: 'public',
          table: 'video_calls',
          filter: PostgresChangeFilter(
            // 2. Typed Filter object
            type: PostgresChangeFilterType.eq,
            column: 'received_by',
            value: seniorId,
          ),
          callback: (payload) {
            // 3. Callback is now a named parameter
            final newCallRecord =
                payload.newRecord; // Helper to get the 'new' map
            final roomUrl = newCallRecord['room_url'];

            if (roomUrl != null) {
              print("📞 Incoming call detected! Room: $roomUrl");
              navigatorKey.currentState?.push(
                MaterialPageRoute(builder: (_) => VideoCallPage(url: roomUrl)),
              );
            }
          },
        )
        .subscribe();
  }

  void _handleIncomingCall(String url) {
    // 💡 THE MAGIC: Use the global key to navigate without context
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => VideoCallPage(url: url)),
    );
  }

  // Stop listening (call this on logout)
  void stopListening() {
    if (_channel != null) {
      _supabase.removeChannel(_channel!);
      _channel = null;
    }
  }
}

// Create a global instance for easy access
final callListener = CallListenerService();

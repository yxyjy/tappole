// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../main.dart';
// import '../pages/video_call/video_call_page.dart';
// import '../components/feedback_dialog.dart'; // <--- Import this

// class CallListenerService {
//   final _supabase = Supabase.instance.client;
//   RealtimeChannel? _channel;

//   void startListening(String seniorId) {
//     if (_channel != null) return;

//     print("🎧 Started listening for calls for Senior: $seniorId");

//     _channel = _supabase.channel('public:video_calls');

//     _channel!
//         .onPostgresChanges(
//           event: PostgresChangeEvent.insert,
//           schema: 'public',
//           table: 'video_calls',
//           filter: PostgresChangeFilter(
//             type: PostgresChangeFilterType.eq,
//             column: 'received_by',
//             value: seniorId,
//           ),
//           callback: (payload) {
//             print("🔔 Incoming call event received!");
//             _handleIncomingCall(payload.newRecord);
//           },
//         )
//         .subscribe();
//   }

//   // --- UPDATED HANDLER ---
//   Future<void> _handleIncomingCall(Map<String, dynamic> record) async {
//     final String? callId = record['request_id'];
//     final currentUser = _supabase.auth.currentUser;

//     if (callId != null &&
//         currentUser != null &&
//         navigatorKey.currentState != null) {
//       print("📞 Starting Call UI. Call ID: $callId");

//       // 1. Push the Video Call Page and WAIT (await) for it to close
//       await navigatorKey.currentState!.push(
//         MaterialPageRoute(
//           builder: (_) => VideoCallPage(
//             callId: callId,
//             userId: currentUser.id,
//             userName: currentUser.userMetadata?['first_name'] ?? 'Senior',
//             // isSenior: true, // If you added the flag to VideoCallPage, pass it here
//           ),
//         ),
//       );

//       // 2. CODE HERE RUNS AFTER THE CALL ENDS (User hung up)
//       print("🏁 Call ended. Showing Feedback Dialog.");

//       final context = navigatorKey.currentContext;

//       if (context != null && context.mounted) {
//         showDialog(
//           context: context,
//           barrierDismissible: false, // Force them to rate
//           builder: (_) => FeedbackDialog(
//             requestId: callId, // Pass the ID so we know what request to rate
//           ),
//         );
//       }
//     } else {
//       print("⚠️ Call detected but missing data or Navigator.");
//     }
//   }

//   void stopListening() {
//     if (_channel != null) {
//       print("🛑 Stopped listening for calls.");
//       _supabase.removeChannel(_channel!);
//       _channel = null;
//     }
//   }
// }

// final callListener = CallListenerService();

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
              userId: currentUser.id,
              userName: "Senior", // Or fetch real name
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
            builder: (_) => FeedbackDialog(requestId: callId),
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

  /// Stop listening (Call this on Logout)
  Future<void> stopListening() async {
    // If the channel is already null, do nothing
    if (_channel == null) return;

    print("🛑 Safely removing channel...");

    // 1. Copy the channel to a temp variable
    final tempChannel = _channel;

    // 2. Nullify the global variable IMMEDIATELY to prevent race conditions
    _channel = null;

    try {
      // 3. Unsubscribe on the temp variable
      await _supabase.removeChannel(tempChannel!);
    } catch (e) {
      print("⚠️ Channel already disconnected or error removing: $e");
    }
  }
}

// Global instance
final callListener = CallListenerService();

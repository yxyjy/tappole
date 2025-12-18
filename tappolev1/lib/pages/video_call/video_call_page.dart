// import 'package:flutter/material.dart';
// // import 'package:zego_uiki/zego_uiki.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// class VideoCallPage extends StatelessWidget {
//   final String callId; // This will be the request_id
//   final String userId;
//   final String userName;

//   const VideoCallPage({
//     super.key,
//     required this.callId,
//     required this.userId,
//     required this.userName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const int appID = 945550209;
//     const String appSign =
//         "225afaa38cde36702fa483c447b56d75a16e73ec026f71f2a69047e8c1a2215d";

//     return ZegoUIKitPrebuiltCall(
//       appID: appID,
//       appSign: appSign,
//       userID: userId,
//       userName: userName,
//       callID: callId,

//       // Configuration for a 1-on-1 Video Call
//       config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),

//       events: ZegoUIKitPrebuiltCallEvents(
//         onCallEnd: (event, defaultAction) {
//           Navigator.of(context).pop();
//         },
//       ),
//     );
//   }
// }

import 'dart:async'; // Required for Timer
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart'; // Optional: If you use the signaling plugin

class VideoCallPage extends StatefulWidget {
  final String callId;
  final String volunteerUserId;
  final String volunteerUserName;

  const VideoCallPage({
    super.key,
    required this.callId,
    required this.volunteerUserId,
    required this.volunteerUserName,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  Timer? _safetyTimer;
  bool _hasJoined = false;

  @override
  void initState() {
    super.initState();

    _safetyTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && !_hasJoined) {
        print("⚠️ Video Call Init Timed Out - Force Closing");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Connection timed out. Please check your internet or permissions.",
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );

        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _safetyTimer?.cancel(); // Always clean up the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const int appID = 945550209;
    const String appSign =
        "225afaa38cde36702fa483c447b56d75a16e73ec026f71f2a69047e8c1a2215d";

    return ZegoUIKitPrebuiltCall(
      appID: appID,
      appSign: appSign,
      userID: widget.volunteerUserId,
      userName: widget.volunteerUserName,
      callID: widget.callId,

      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),

      events: ZegoUIKitPrebuiltCallEvents(
        room: ZegoCallRoomEvents(
          onStateChanged: (ZegoUIKitRoomState event) {
            print("🎥 Zego Room State: $event");

            if (event.reason == ZegoRoomStateChangedReason.Logined) {
              setState(() {
                _hasJoined = true;
              });
              _safetyTimer?.cancel(); // 🛑 Stop the timer
              print("✅ Connected successfully. Safety timer cancelled.");
            }
          },
        ),

        onCallEnd: (event, defaultAction) {
          print("🏁 Call ended by user.");
          _safetyTimer?.cancel();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

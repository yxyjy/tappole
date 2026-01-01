import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tappolev1/components/styled_snackbar.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

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

    //timeout after 30 seconds if not connected
    _safetyTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && !_hasJoined) {
        //debug print
        print("Forcefully ending call due to timeout.");

        StyledSnackbar.show(
          context: context,
          message:
              "Connection timed out. Please check your internet or permissions.",
          type: SnackbarType.error,
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
    //old call api ID
    // const int appID = 945550209;
    // const String appSign =
    //     "225afaa38cde36702fa483c447b56d75a16e73ec026f71f2a69047e8c1a2215d";

    //new call api ID
    const int appID = 430728164;
    const String appSign =
        "5f0034ccb83a9a58af53cc1350d8776e907aca955fd0704f546c8b02a5011ef7";

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
              _safetyTimer?.cancel();
              print("Connected successfully. Safety timer cancelled.");
            }
          },
        ),

        onCallEnd: (event, defaultAction) {
          print("Call ended by user.");
          _safetyTimer?.cancel();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

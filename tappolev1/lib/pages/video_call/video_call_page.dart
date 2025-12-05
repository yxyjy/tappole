import 'package:flutter/material.dart';
// import 'package:zego_uiki/zego_uiki.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCallPage extends StatelessWidget {
  final String callId; // This will be the request_id
  final String userId;
  final String userName;

  const VideoCallPage({
    super.key,
    required this.callId,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    const int appID = 945550209;
    const String appSign =
        "225afaa38cde36702fa483c447b56d75a16e73ec026f71f2a69047e8c1a2215d";

    return ZegoUIKitPrebuiltCall(
      appID: appID,
      appSign: appSign,
      userID: userId,
      userName: userName,
      callID: callId,

      // Configuration for a 1-on-1 Video Call
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),

      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (event, defaultAction) {
          // This triggers when the call is finished (hangup or remote user left)
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

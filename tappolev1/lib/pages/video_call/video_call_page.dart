import 'package:flutter/material.dart';

class VideoCallPage extends StatefulWidget {
  final String url;
  const VideoCallPage({super.key, required this.url});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Call Page')),
      body: Center(
        child: Text(
          'Video Call functionality for ${widget.url} will be implemented here.',
        ),
      ),
    );
  }
}

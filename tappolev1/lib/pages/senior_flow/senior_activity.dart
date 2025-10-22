import 'package:flutter/material.dart';

class SeniorActivityPage extends StatefulWidget {
  const SeniorActivityPage({super.key});
  @override
  _SeniorActivityPageState createState() => _SeniorActivityPageState();
}

class _SeniorActivityPageState extends State<SeniorActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Welcome to the Senior Activity Page!')),
    );
  }
}

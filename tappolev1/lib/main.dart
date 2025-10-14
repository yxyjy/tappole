import 'package:flutter/material.dart';
// import 'pages/login.dart';
import 'pages/loginflow.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginFlowPage(),
    );
  }
}

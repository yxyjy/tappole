import 'package:flutter/material.dart';
import 'package:tappolev1/pages/auth/main_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://bljiwlqzmukrqdvzhfau.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJsaml3bHF6bXVrcnFkdnpoZmF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEzMDIyNjIsImV4cCI6MjA3Njg3ODI2Mn0.17HwBVRfcK0UBmgiV3om22TudqddQNYJ8jR2yW3uvdg',
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainAuth(),
    );
  }
}

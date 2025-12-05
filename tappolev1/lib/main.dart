import 'package:flutter/material.dart';
import 'package:tappolev1/pages/auth/emailloginflow.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://poyqpdeqayeuxpxzccas.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBveXFwZGVxYXlldXhweHpjY2FzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEzODg0MjMsImV4cCI6MjA3Njk2NDQyM30._F726QxQw0t1yZ0-fBNgwi8N2r541a32FfLybX-diiQ',
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: Emailloginflow(),
    );
  }
}

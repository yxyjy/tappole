import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tappolev1/pages/auth/main_auth.dart';
import 'package:tappolev1/pages/senior_flow/senior_home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,

      builder: (context, snapshot) {
        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        //authenticated
        if (session != null) {
          return const SeniorHomePage();
        }

        //unauthenticated
        return const MainAuth();
      },
    );
  }
}

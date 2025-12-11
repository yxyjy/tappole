import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tappolev1/services/auth_service.dart'; // Import your specific AuthService
import 'package:tappolev1/components/senior_navbar.dart';
import 'package:tappolev1/components/volunteer_navbar.dart';
import 'package:tappolev1/pages/auth/emailloginflow.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      // Listen to login/logout changes
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        print("AuthGate: Connection State -> ${snapshot.connectionState}");
        print("AuthGate: Has Data? -> ${snapshot.hasData}");
        print("AuthGate: Session -> ${snapshot.data?.session}");

        // Waiting for Supabase to check session...
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Check if we already have a session in the client despite the stream waiting
          // This is a common fix for "flickering" or "stuck" states
          final currentSession = Supabase.instance.client.auth.currentSession;
          if (currentSession != null) {
            // If we have a session, don't show loading, fall through to logic below
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        }

        final session =
            snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;

        // If NOT logged in, show Login Page
        if (session != null) {
          // User is logged in!
          print("AuthGate: User detected! ID: ${session.user.id}"); // Debug

          return FutureBuilder<String?>(
            future: _authService.getCurrentUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final role = roleSnapshot.data;
              print("AuthGate: Role is $role"); // Debug

              if (role == 'volunteer') {
                return const VolunteerNavBar(initialIndex: 1);
              } else {
                return const SeniorNavBar(initialIndex: 1);
              }
            },
          );
        } else {
          // User is NOT logged in
          print("AuthGate: No session found. Showing Login Page."); // Debug
          return const Emailloginflow();
        }
      },
    );
  }
}

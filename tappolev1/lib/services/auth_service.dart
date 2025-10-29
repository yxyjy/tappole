import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Signs in a user using email and password.
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Signs up a user using email and password.
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  ///Signs out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  //get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Future<String?> getCurrentUserRole() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    try {
      final data = await _supabase
          .schema('public')
          .from('profiles')
          .select('role') // Only select the 'role' column
          .eq('id', user.id) // Find the row where 'id' matches the user's ID
          .single(); // Expect only one row

      // 4. Extract and return the role
      return data['role'] as String?;
    } catch (e) {
      // 5. Handle potential errors (e.g., profile not found, network error)
      print('Error fetching user role: $e');
      return null;
    }
  }
}

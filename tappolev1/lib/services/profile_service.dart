import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  /// Fetches the profile for the currently logged-in user
  Future<UserProfile> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final data = await _supabase
          .from('profiles')
          .select() // Select all columns
          .eq('id', user.id)
          .single(); // Expect one row

      // Convert the Map<String, dynamic> to your UserProfile object
      return UserProfile.fromMap(data);
    } catch (e) {
      print('Error fetching profile: $e');
      // Re-throw the error to be handled by the UI
      throw Exception('Could not fetch profile');
    }
  }

  // You can add other profile-related methods here later...
  Future<void> updateProfile(UserProfile profile) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      await _supabase
          .from('profiles')
          .update(profile.toMap())
          .eq('id', user.id);
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Could not update profile');
    }
  }
}

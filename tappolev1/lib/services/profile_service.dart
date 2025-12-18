import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
//import 'dart:io';

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

  Future<String?> uploadAvatar(XFile imageFile, String userId) async {
    try {
      // 1. Read bytes (Works on Web & Mobile)
      final bytes = await imageFile.readAsBytes();

      // 2. Extract file extension
      final fileExt = imageFile.name.split('.').last;
      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // 3. Upload Binary
      await _supabase.storage
          .from('profile_pictures')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      // 4. Get URL
      final imageUrl = _supabase.storage
          .from('profile_pictures')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  Future<void> updateProfileAvatar(String userId, String avatarUrl) async {
    await _supabase
        .from('profiles')
        .update({'profile_picture': avatarUrl})
        .eq('id', userId);
  }

  Future<Map<String, dynamic>?> getPublicUserInfo(String userId) async {
    print("🔍 FETCHING PROFILE FOR ID: $userId"); // Is this ID valid?

    try {
      final data = await _supabase
          .from('profiles')
          .select('first_name, last_name, profile_picture')
          .eq('id', userId)
          .maybeSingle(); // Use maybeSingle() instead of single() to avoid crashing on missing rows

      if (data == null) {
        print("❌ NO PROFILE FOUND for ID: $userId (Check your database!)");
        return null;
      }

      print("✅ FOUND DATA: $data");
      return data;
    } catch (e) {
      print("❌ CRITICAL ERROR fetching profile: $e");
      return null;
    }
  }
}

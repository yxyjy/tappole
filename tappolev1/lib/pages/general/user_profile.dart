import 'package:flutter/material.dart';
import 'package:tappolev1/pages/general/edit_profile.dart';
import 'package:tappolev1/services/profile_service.dart';
import 'package:tappolev1/models/profile.dart';
import 'package:tappolev1/theme/app_styles.dart';
import '../../components/outlined_button.dart';
import '../../theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.getProfile();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = _profileService.getProfile();
    });
  }

  void _navigateToEdit(UserProfile profile) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(initialProfile: profile),
      ),
    );
    _refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/profilebg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<UserProfile>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('Profile not found.'));
            }

            final profile = snapshot.data!;

            return Stack(
              children: [
                Positioned.fill(
                  top: 150,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ListView(
                      padding: const EdgeInsets.only(
                        top: 120.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      children: [
                        Text(
                          'Hey, ${profile.firstName}!',
                          textAlign: TextAlign.center,
                          style: primaryh2TextStyle,
                        ),
                        const SizedBox(height: 30),

                        // Profile Details
                        _buildProfileDetailTile(
                          icon: Icons.phone,
                          title: 'Phone',
                          subtitle: profile.phone,
                        ),
                        _buildProfileDetailTile(
                          icon: Icons.cake,
                          title: 'Birthday',
                          subtitle:
                              '${profile.dob.day}/${profile.dob.month}/${profile.dob.year}',
                        ),
                        _buildProfileDetailTile(
                          icon: Icons.person,
                          title: 'Role',
                          subtitle: profile.role.toUpperCase(),
                        ),

                        const SizedBox(height: 40),

                        // Edit Profile Button
                        PrimaryOutlinedButton(
                          text: 'Edit Profile',
                          onPressed: () {
                            _navigateToEdit(profile);
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // 2. FIXED HEADER (Settings Button)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  child: TextButton.icon(
                    onPressed: () {
                      /* Handle Settings navigation */
                    },
                    icon: const Icon(Icons.settings, color: Colors.white),
                    label: const Text(
                      'Settings',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                // 3. AVATAR (Highest Z-Index)
                Positioned(
                  top: 70, // Adjust this to control the vertical position
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/user_avatar.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Helper Methods ---
  Widget _buildProfileDetailTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: orangeLabelTextStyle),
          const SizedBox(height: 3),
          Container(
            // 1. Add Decoration for the Border and Radius
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.lowerAlphaDarkBlue,
                width: 0.7,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),

            // 2. Add Padding inside the border
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(icon, color: AppColors.primaryOrange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(subtitle, style: mediumAlphaInputTextStyle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

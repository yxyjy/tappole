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
                  top: 70,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lowerAlphaDarkBlue,
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        top: 87.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26.0),
                        child: Column(
                          children: [
                            Text(
                              'Hey, ${profile.firstName}!',
                              textAlign: TextAlign.center,
                              style: primaryh2TextStyle.copyWith(fontSize: 30),
                            ),
                            const SizedBox(height: 15),

                            // Profile Details
                            _buildProfileDetailTile(
                              icon: Icons.person,
                              title: 'First Name',
                              subtitle: profile.firstName,
                            ),
                            _buildProfileDetailTile(
                              icon: Icons.person,
                              title: 'Last Name',
                              subtitle: profile.lastName,
                            ),
                            _buildProfileDetailTile(
                              icon: Icons.mail,
                              title: 'Email',
                              subtitle: 'email placeholder',
                              //TODO: use join query to get email from auth table
                            ),
                            _buildProfileDetailTile(
                              icon: Icons.phone,
                              title: 'Phone Number',
                              subtitle: profile.phone,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start, // Align tops
                              children: [
                                // 1. Wrap the first tile in Expanded
                                Expanded(
                                  child: _buildProfileDetailTile(
                                    icon: Icons.cake,
                                    title: 'Date of Birth',
                                    subtitle:
                                        '${profile.dob.day}/${profile.dob.month}/${profile.dob.year}',
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ), // Add spacing between them
                                // 2. Wrap the second tile in Expanded
                                Expanded(
                                  child: _buildProfileDetailTile(
                                    icon: Icons.person,
                                    title: 'Role',
                                    subtitle: profile.role.toUpperCase(),
                                  ),
                                ),
                              ],
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
                  ),
                ),

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

                Positioned(
                  top: 30, // Adjust this to control the vertical position
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        border: Border.all(color: AppColors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.lowerAlphaDarkBlue,
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                width: 0.75,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),

            // 2. Add Padding inside the border
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
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

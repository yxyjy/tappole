import 'package:flutter/material.dart';
//import 'package:tappolev1/components/primary_button.dart';
import 'package:tappolev1/pages/auth/emailloginflow.dart';
import 'package:tappolev1/pages/general/edit_profile.dart';
import 'package:tappolev1/services/auth_service.dart';
import 'package:tappolev1/services/profile_service.dart';
import 'package:tappolev1/models/profile.dart';
import 'package:tappolev1/theme/app_styles.dart';
import '../../components/outlined_button.dart';
import '../../theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.getProfile();
  }

  void _refreshProfile() {
    if (mounted) {
      setState(() {
        _profileFuture = _profileService.getProfile();
      });
    }
  }

  void _navigateToEdit(UserProfile profile) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(initialProfile: profile),
      ),
    );
    if (mounted) {
      _refreshProfile();
    }
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
            final email = _authService.getCurrentUserEmail();

            ImageProvider avatarImage;
            if (profile.profilePictureUrl != null &&
                profile.profilePictureUrl!.isNotEmpty) {
              avatarImage = NetworkImage(profile.profilePictureUrl!);
            } else {
              avatarImage = const AssetImage('assets/images/user_avatar.png');
            }

            return Stack(
              children: [
                Positioned.fill(
                  top: 120,
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
                        top: 75.0,
                        left: 12.0,
                        right: 12.0,
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
                            const SizedBox(height: 12),

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
                              subtitle: email ?? 'No email',
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
                                Expanded(
                                  child: _buildProfileDetailTile(
                                    icon: Icons.cake,
                                    title: 'Date of Birth',
                                    subtitle:
                                        '${profile.dob.day}/${profile.dob.month}/${profile.dob.year}',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildProfileDetailTile(
                                    icon: Icons.person,
                                    title: 'Role',
                                    subtitle: profile.role.toUpperCase(),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Edit Profile Button
                            PrimaryOutlinedButton(
                              text: 'Edit Profile',
                              onPressed: () {
                                _navigateToEdit(profile);
                              },
                            ),
                            // const SizedBox(height: 70),

                            // PrimaryButton(
                            //   text: "Log Out",
                            //   onPressed: () async {
                            //     await _authService.signOut();

                            //     if (context.mounted) {
                            //       Navigator.of(context).pushAndRemoveUntil(
                            //         MaterialPageRoute(
                            //           builder: (context) =>
                            //               const Emailloginflow(),
                            //         ),
                            //         (route) => false,
                            //       );
                            //     }
                            //   },
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: MediaQuery.of(context).padding.top + 15,
                  left: 15,
                  child: TextButton.icon(
                    onPressed: () async {
                      await _authService.signOut();

                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const Emailloginflow(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: AppColors.primaryOrange,
                      size: 30,
                    ),
                    label: const Text(
                      '',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  top: 70, // Adjust this to control the vertical position
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
                        image: DecorationImage(
                          image: avatarImage,
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

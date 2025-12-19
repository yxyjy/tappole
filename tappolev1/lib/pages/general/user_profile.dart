import 'package:flutter/material.dart';
import 'package:tappolev1/auth_gate.dart';
import 'package:tappolev1/pages/auth/emailloginflow.dart';
import 'package:tappolev1/pages/general/edit_profile.dart';
import 'package:tappolev1/services/auth_service.dart';
import 'package:tappolev1/services/profile_service.dart';
import 'package:tappolev1/services/request_service.dart'; // Import RequestService
import 'package:tappolev1/models/profile.dart';
import 'package:tappolev1/theme/app_styles.dart';
import '../../components/outlined_button.dart';
import '../../theme/app_colors.dart';
import '../../components/textsize_adjuster.dart';
import '../../components/primary_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  final RequestService _requestService = RequestService(); // Add RequestService

  late Future<UserProfile> _profileFuture;

  // We'll store stats here
  Future<Map<String, dynamic>>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.getProfile();
  }

  void _refreshProfile() {
    if (mounted) {
      setState(() {
        _profileFuture = _profileService.getProfile();
        // Reset stats future so it refreshes too if needed
        _statsFuture = null;
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

  Future<Map<String, dynamic>> _fetchStats(String role, String userId) {
    if (_statsFuture != null) return _statsFuture!;

    if (role == 'volunteer') {
      _statsFuture = _requestService.getVolunteerStats(userId);
    } else {
      _statsFuture = _requestService.getSeniorStats(userId);
    }
    return _statsFuture!;
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

            // Determine Avatar
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
                  top: 120, // Adjusted position
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      // Reduced top padding as avatar is now inside
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        left: 24,
                        right: 24,
                        bottom: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // border: Border.all(
                                  //   color: Colors.white,
                                  //   width: 4,
                                  // ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(30),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 40, // Avatar size
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: avatarImage,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ), // Spacing between avatar and name
                              Expanded(
                                child: Text(
                                  'Hey,\n${profile.firstName}!',
                                  textAlign: TextAlign.left,
                                  style: primaryh2TextStyle.copyWith(
                                    fontSize: 28,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          FutureBuilder<Map<String, dynamic>>(
                            future: _fetchStats(profile.role, profile.id),
                            builder: (context, statsSnapshot) {
                              String leftLabel = "Requests";
                              String leftValue = "-";
                              String rightLabel = "Rating";
                              String rightValue = "-";

                              if (statsSnapshot.hasData) {
                                final stats = statsSnapshot.data!;
                                if (profile.role == 'volunteer') {
                                  // Volunteer Stats
                                  leftLabel = "Requests\nCompleted";
                                  leftValue = stats['completed'].toString();
                                  rightLabel = "Average\nRating";
                                  rightValue = stats['rating'].toString();
                                } else {
                                  // Senior Stats
                                  leftLabel = "Requests\nMade";
                                  leftValue = stats['total'].toString();
                                  rightLabel = "Requests\nAccepted";
                                  rightValue = stats['accepted'].toString();
                                }
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildStatBox(leftLabel, leftValue),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildStatBox(
                                      rightLabel,
                                      rightValue,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          _buildSimpleDetail(
                            Icons.person,
                            'First Name',
                            profile.firstName,
                          ),
                          _buildSimpleDetail(
                            Icons.person,
                            'Last Name',
                            profile.lastName,
                          ),
                          _buildSimpleDetail(
                            Icons.email,
                            'Email',
                            email ?? '-',
                          ),
                          _buildSimpleDetail(
                            Icons.phone,
                            'Phone Number',
                            profile.phone,
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: _buildSimpleDetail(
                                  Icons.cake,
                                  'Birthday',
                                  '${profile.dob.day}/${profile.dob.month}/${profile.dob.year}',
                                ),
                              ),
                              Expanded(
                                child: _buildSimpleDetail(
                                  Icons.person,
                                  'Gender',
                                  profile.gender ?? '-',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          Center(
                            child: PrimaryOutlinedButton(
                              text: 'Edit Profile',
                              onPressed: () => _navigateToEdit(profile),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _showConfirmLogoutDialog(context),
                        // onTap: () async {
                        //   await _authService.signOut();
                        //   if (context.mounted) {
                        //     Navigator.of(context).pushAndRemoveUntil(
                        //       MaterialPageRoute(
                        //         builder: (context) => const Emailloginflow(),
                        //       ),
                        //       (route) => false,
                        //     );
                        //   }
                        // },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(204),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.primaryOrange,
                            size: 24,
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: _showDisplaySettings,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(204),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.text_format,
                            color: AppColors.primaryOrange,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFBCE7DF),
          width: 1,
        ), // Light peach border
        // boxShadow: const [
        //   BoxShadow(
        //     color: Color(0x0D000000), // Very subtle shadow
        //     blurRadius: 10,
        //     offset: Offset(0, 4),
        //   ),
        // ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            label,
            style: primarypTextStyle.copyWith(
              color: AppColors.primaryOrange,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: primaryh2TextStyle.copyWith(
              fontSize: 24,
              color: AppColors.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDetail(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: primarypTextStyle.copyWith(
              fontSize: 14,
              color: AppColors.primaryOrange,
            ),
          ),

          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, color: AppColors.mediumAlphaDarkBlue, size: 16),
              SizedBox(width: 6),
              Text(
                value,
                style: primarypTextStyle.copyWith(
                  color: AppColors.mediumAlphaDarkBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDisplaySettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content height
            children: [
              Text(
                "Display Settings",
                style: primaryh2TextStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 20),
              const TextSizeAdjuster(), // <--- YOUR NEW COMPONENT
              const SizedBox(height: 20),
              PrimaryButton(
                text: "Done",
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Confirm Log Out",
          style: primarypTextStyle.copyWith(fontSize: 20),
        ),
        content: Text(
          "Are you sure you want to log out?",
          style: primarypTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "No",
              style: primarypTextStyle.copyWith(color: Colors.grey),
            ),
          ),

          // 'Yes' Button
          PrimaryButton(
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthGate()),
                  (route) => false,
                );
              }
            },
            text: "Log Out",
          ),
          // TextButton(
          //   onPressed: () async {
          //     await _authService.signOut();
          //     if (context.mounted) {
          //       Navigator.of(context).pushAndRemoveUntil(
          //         MaterialPageRoute(builder: (context) => const AuthGate()),
          //         (route) => false,
          //       );
          //     }
          //   },
          //   // onPressed: () async {
          //   //   try {
          //   //     await _requestService.cancelRequest(request.req_id);

          //   //     if (context.mounted) {
          //   //       Navigator.of(context).pop();
          //   //       Navigator.of(context).pop();

          //   //       setState(() {
          //   //         _requestsFuture = _requestService.getRequestsBySenior();
          //   //       });

          //   //       ScaffoldMessenger.of(context).showSnackBar(
          //   //         SnackBar(
          //   //           content: Text(
          //   //             "Request cancelled successfully",
          //   //             style: primarypTextStyle,
          //   //           ),
          //   //           backgroundColor: Colors.grey,
          //   //         ),
          //   //       );
          //   //     }
          //   //   } catch (e) {
          //   //     print("Cancel Error: $e");
          //   //     if (context.mounted) {
          //   //       Navigator.pop(context);
          //   //       ScaffoldMessenger.of(context).showSnackBar(
          //   //         SnackBar(
          //   //           content: Text(
          //   //             "Failed to cancel: $e",
          //   //             style: primarypTextStyle,
          //   //           ),
          //   //         ),
          //   //       );
          //   //     }
          //   //   }
          //   // },
          //   child: Text(
          //     "Yes, Log Out",
          //     style: primarypTextStyle.copyWith(
          //       color: Colors.red,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

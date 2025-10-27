import 'package:flutter/material.dart';
import 'package:tappolev1/services/profile_service.dart';
import 'package:tappolev1/models/profile.dart';

class SeniorProfilePage extends StatefulWidget {
  const SeniorProfilePage({super.key});
  @override
  _SeniorProfilePageState createState() => _SeniorProfilePageState();
}

class _SeniorProfilePageState extends State<SeniorProfilePage> {
  final ProfileService _profileService = ProfileService();
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    // Call the service method here
    _profileFuture = _profileService.getProfile();
  }

  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Container(
  //       width: double.infinity,
  //       height: double.infinity,
  //       padding: const EdgeInsets.symmetric(horizontal: 30.0),
  //       decoration: const BoxDecoration(
  //         image: DecorationImage(
  //           image: AssetImage('assets/images/seniorhomebg.png'),
  //           fit: BoxFit.cover,
  //         ),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const SizedBox(height: 70),
  //           const Center(
  //             child: CircleAvatar(
  //               radius: 60,
  //               backgroundImage: NetworkImage(
  //                 'https://via.placeholder.com/150',
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           const Center(
  //             child: Text(
  //               'John Doe',
  //               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           const Center(
  //             child: Text(
  //               'john.doe@example.com',
  //               style: TextStyle(fontSize: 16, color: Colors.grey),
  //             ),
  //           ),
  //           const SizedBox(height: 24),
  //           const Divider(),
  //           const ListTile(
  //             leading: Icon(Icons.phone),
  //             title: Text('Phone'),
  //             subtitle: Text('+1 234 567 890'),
  //           ),
  //           const ListTile(
  //             leading: Icon(Icons.home),
  //             title: Text('Address'),
  //             subtitle: Text('123 Main St, Anytown, USA'),
  //           ),
  //           const ListTile(
  //             leading: Icon(Icons.cake),
  //             title: Text('Birthday'),
  //             subtitle: Text('January 1, 1950'),
  //           ),
  //           const Spacer(),
  //           Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: SizedBox(
  //               width: double.infinity,
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   // TODO: Navigate to an edit profile page
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   padding: const EdgeInsets.symmetric(vertical: 16),
  //                 ),
  //                 child: const Text('Edit Details'),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture, // Use the Future from your state
        builder: (context, snapshot) {
          // --- 1. Loading State ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- 2. Error State ---
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // --- 3. No Data State ---
          if (!snapshot.hasData) {
            return const Center(child: Text('Profile not found.'));
          }

          // --- 4. Success State ---
          final profile = snapshot.data!; // We have our UserProfile object!

          // Build your UI using the profile data
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                '${profile.firstName} ${profile.lastName}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(profile.phone),
              ),
              ListTile(
                leading: const Icon(Icons.cake),
                title: Text(
                  'Born on ${profile.dob.day}/${profile.dob.month}/${profile.dob.year}',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(profile.role), // e.g., "senior"
              ),
            ],
          );
        },
      ),
    );
  }
}

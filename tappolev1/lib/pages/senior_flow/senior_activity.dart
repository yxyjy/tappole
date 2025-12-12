import 'package:flutter/material.dart';
import '../../services/request_service.dart';
import '../../services/profile_service.dart'; // Import ProfileService
import '../../models/request.dart';
import '../../models/profile.dart'; // Import UserProfile model
import '../../theme/app_styles.dart';
import '../../theme/app_colors.dart'; // Assuming you have this

class SeniorActivityPage extends StatefulWidget {
  const SeniorActivityPage({super.key});

  MaterialPageRoute<void> get route {
    return MaterialPageRoute<void>(builder: (_) => const SeniorActivityPage());
  }

  @override
  State<SeniorActivityPage> createState() => _SeniorActivityPageState();
}

class _SeniorActivityPageState extends State<SeniorActivityPage> {
  late final RequestService _requestService;
  final ProfileService _profileService =
      ProfileService(); // Initialize ProfileService

  late Future<List<Request>> _requestsFuture;
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _requestService = RequestService();
    // 1. Fetch Requests
    _requestsFuture = _requestService.getRequestsBySenior();
    // 2. Fetch Own Profile (to display name/pic on cards)
    _profileFuture = _profileService.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
        ), // Reduced padding for wider cards
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/seniorhomebg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 100),
            Text(
              'Your Requests',
              textAlign: TextAlign.center,
              style: primaryh2TextStyle,
            ),
            const SizedBox(height: 15),
            Text(
              'Edit your active requests or view your previous requests.',
              style: primarypTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            Expanded(
              child: FutureBuilder<UserProfile>(
                future: _profileFuture,
                builder: (context, profileSnapshot) {
                  if (!profileSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final UserProfile userProfile = profileSnapshot.data!;

                  return FutureBuilder<List<Request>>(
                    future: _requestsFuture,
                    builder: (context, requestSnapshot) {
                      if (requestSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (requestSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${requestSnapshot.error}'),
                        );
                      }
                      if (!requestSnapshot.hasData ||
                          requestSnapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'You have no requests yet.',
                            style: TextStyle(color: Color(0xFF192133)),
                          ),
                        );
                      }

                      final List<Request> requests = requestSnapshot.data!;

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          return _buildRequestCard(
                            context,
                            requests[index],
                            userProfile, // Pass profile to the card
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    Request request,
    UserProfile profile,
  ) {
    final String status = request.req_status;
    Color statusBgColor;
    Color statusTextColor = AppColors.primaryDarkBlue;

    // Status Colors (Matching Volunteer View)
    switch (status) {
      case 'pending':
        statusBgColor = const Color(0xFFFFC525);
        break;
      case 'accepted':
        statusBgColor = const Color(0xFF27B533);
        statusTextColor = Colors.white;
        break;
      case 'completed':
        statusBgColor = const Color.fromARGB(255, 39, 70, 181);
        statusTextColor = Colors.white;
        break;
      case 'cancelled':
        statusBgColor = const Color(0xFFC84949);
        statusTextColor = Colors.white;
        break;
      default:
        statusBgColor = Colors.grey.shade300;
    }

    // Determine Avatar Image
    ImageProvider avatarImage;
    if (profile.profilePictureUrl != null &&
        profile.profilePictureUrl!.isNotEmpty) {
      avatarImage = NetworkImage(profile.profilePictureUrl!);
    } else {
      avatarImage = const AssetImage('assets/images/user_avatar.png');
    }

    return Card(
      elevation: 0.5, // Flat style
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          _showRequestDetails(context, request, profile);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: avatarImage,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${profile.firstName} ${profile.lastName}",
                    style: primaryh2TextStyle.copyWith(fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (request.req_title != null) ...[
                Text(
                  request.req_title!,
                  style: primaryh2TextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 10),
              ],

              Text(
                request.req_content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: primarypTextStyle.copyWith(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      status[0].toUpperCase() + status.substring(1),
                      style: primarypTextStyle.copyWith(
                        fontSize: 14,
                        color: statusTextColor,
                      ),
                    ),
                  ),
                  Text(
                    request.created_at.toString().substring(0, 16),
                    style: primarypTextStyle.copyWith(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestDetails(
    BuildContext context,
    Request request,
    UserProfile profile,
  ) {
    final String status = request.req_status;

    // 1. Determine Status Colors (Same logic as cards)
    Color statusBgColor;
    Color statusTextColor = Colors.black;

    switch (status) {
      case 'pending':
        statusBgColor = const Color(0xFFFFC525);
        break;
      case 'accepted':
        statusBgColor = const Color(0xFFF06638);
        statusTextColor = Colors.white;
        break;
      case 'completed':
        statusBgColor = const Color(0xFF27B533);
        statusTextColor = Colors.white;
        break;
      case 'cancelled':
        statusBgColor = const Color(0xFFC84949);
        statusTextColor = Colors.white;
        break;
      default:
        statusBgColor = Colors.grey.shade300;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content
            children: [
              // --- ROW 1: Timestamp (Left) & Status (Right) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.created_at.toString().substring(0, 16),
                    style: const TextStyle(
                      fontFamily: 'Archivo',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF192133),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status[0].toUpperCase() + status.substring(1),
                      style: TextStyle(
                        fontFamily: 'Archivo',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: statusTextColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.req_title ?? "Request Details",
                      style: const TextStyle(
                        fontFamily: 'Archivo',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF192133),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Content
                    Text(
                      request.req_content,
                      style: const TextStyle(
                        fontFamily: 'Archivo',
                        fontSize: 15,
                        height: 1.5,
                        color: Color(0xFF192133),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              if (status == 'pending')
                SizedBox(
                  width: double.infinity, // Full width
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF06638), // Orange
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      // TODO: Navigate to your Edit Page here
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => EditRequestPage(request: request)));
                    },
                    child: const Text(
                      "Edit",
                      style: TextStyle(
                        fontFamily: 'Archivo',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

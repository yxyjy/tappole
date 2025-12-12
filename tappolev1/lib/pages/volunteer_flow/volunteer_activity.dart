import 'package:flutter/material.dart';
import '../../services/request_service.dart';
import '../../services/profile_service.dart';
import '../../models/request.dart';
import '../../theme/app_styles.dart';
import '../../theme/app_colors.dart';

class VolunteerActivityPage extends StatefulWidget {
  const VolunteerActivityPage({super.key});

  MaterialPageRoute<void> get route {
    return MaterialPageRoute<void>(
      builder: (_) => const VolunteerActivityPage(),
    );
  }

  @override
  State<VolunteerActivityPage> createState() => _VolunteerActivityPageState();
}

class _VolunteerActivityPageState extends State<VolunteerActivityPage> {
  late final RequestService _requestService;
  late Future<List<Request>> _requestsFuture;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _requestService = RequestService();
    _requestsFuture = _requestService.getRequestsForVolunteer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/volunteerhomebg.png'),
            fit: BoxFit.cover,
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Text(
              'Accepted Requests',
              textAlign: TextAlign.center,
              style: primaryh2TextStyle.copyWith(
                color: AppColors.lighterOrange,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'View your previously accepted requests.',
              style: primarypTextStyle.copyWith(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: FutureBuilder<List<Request>>(
                future: _requestsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load requests: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'You have not accepted any requests yet.',
                        style: TextStyle(color: AppColors.primaryDarkBlue),
                      ),
                    );
                  }

                  final List<Request> requests = snapshot.data!;

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final Request request = requests[index];
                      return _buildRequestCard(context, request);
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

  void _showRequestDetails(BuildContext context, Request request) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Wrap content height
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<Map<String, dynamic>?>(
                    future: _profileService.getPublicUserInfo(
                      request.requested_by,
                    ),
                    builder: (context, snapshot) {
                      String name = "Loading...";
                      ImageProvider avatarImage = const AssetImage(
                        'assets/images/user_avatar.png',
                      );

                      if (snapshot.hasData && snapshot.data != null) {
                        final data = snapshot.data!;
                        name = "${data['first_name']} ${data['last_name']}";
                        if (data['profile_picture'] != null) {
                          avatarImage = NetworkImage(data['profile_picture']);
                        }
                      }

                      return Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: avatarImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: primaryh2TextStyle.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Posted on ${request.created_at.toString().substring(0, 16)}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  Text(
                    request.req_content,
                    style: primarypTextStyle.copyWith(
                      color: const Color(0xFF535763),
                      height: 1.5,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, Request request) {
    final String status = request.req_status;

    // 1. Define Styles based on Status (keeping your color logic)
    Color statusBgColor;
    Color statusTextColor = Colors.black; // Default text color

    switch (status) {
      case 'pending':
        statusBgColor = const Color(0xFFFFC525); // Yellow
        break;
      case 'accepted':
        statusBgColor = const Color(0xFFF06638); // Orange
        statusTextColor = Colors.white;
        break;
      case 'completed':
        statusBgColor = const Color(0xFF27B533); // Green
        statusTextColor = Colors.white;
        break;
      case 'cancelled':
        statusBgColor = const Color(0xFFC84949); // Red
        statusTextColor = Colors.white;
        break;
      default:
        statusBgColor = Colors.grey.shade300;
    }

    return GestureDetector(
      // <--- Replaces InkWell
      onTap: () {
        _showRequestDetails(context, request);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Generous padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: _profileService.getPublicUserInfo(request.requested_by),
                builder: (context, snapshot) {
                  String name = "Loading...";
                  ImageProvider avatarImage = const AssetImage(
                    'assets/images/user_avatar.png',
                  );

                  if (snapshot.hasData && snapshot.data != null) {
                    final data = snapshot.data!;
                    name = "${data['first_name']} ${data['last_name']}";
                    if (data['profile_picture'] != null) {
                      avatarImage = NetworkImage(data['profile_picture']);
                    }
                  }

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage: avatarImage,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        name,
                        style: primaryh2TextStyle.copyWith(
                          fontSize: 16,
                        ), // Bold Name
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),

              Text(
                request.req_content,
                style: primarypTextStyle.copyWith(
                  color: const Color(0xFF535763),
                  fontWeight: FontWeight.w200,
                  height: 1.4,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 24),

              // --- FOOTER: Status Badge & Timestamp ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(30), // Stadium shape
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  // Timestamp
                  Text(
                    request.created_at.toString().substring(0, 10),
                    style: primarypTextStyle.copyWith(
                      color: const Color(0xFF535763),
                      fontSize: 12,
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
}

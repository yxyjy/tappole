import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:intl/intl.dart'; // Add this to pubspec.yaml for date formatting if needed
import '../../services/request_service.dart';
import '../../models/request.dart';
import '../../theme/app_styles.dart';
import '../../theme/app_colors.dart';
import '../video_call/video_call_page.dart';
import '../../services/profile_service.dart';
import '../../components/primary_button.dart';
// import '../../components/feedback_dialog.dart';

class VolunteerHomePage extends StatefulWidget {
  const VolunteerHomePage({super.key});

  @override
  State<VolunteerHomePage> createState() => _VolunteerHomePageState();
}

class _VolunteerHomePageState extends State<VolunteerHomePage> {
  late final RequestService _requestService;
  final ProfileService _profileService =
      ProfileService(); // Initialize ProfileService
  late Future<List<Request>> _pendingRequestsFuture;
  late RealtimeChannel _requestsChannel;

  bool _isAscending = false;

  @override
  void initState() {
    super.initState();
    _requestService = RequestService();
    _pendingRequestsFuture = _requestService.getPendingRequestsForVolunteers(
      isAscending: _isAscending,
    );
    _listenForRequestChanges();
  }

  Future<void> _refreshRequests() async {
    if (mounted) {
      setState(() {
        // _pendingRequestsFuture = _requestService
        //     .getPendingRequestsForVolunteers();
        _pendingRequestsFuture = _requestService
            .getPendingRequestsForVolunteers(isAscending: _isAscending);
      });
    }
  }

  void _listenForRequestChanges() {
    _requestsChannel = Supabase.instance.client.channel('public:requests');
    _requestsChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'requests',
          callback: (payload) {
            print("🔔 Request Table Updated! Refreshing UI...");
            _refreshRequests();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    Supabase.instance.client.removeChannel(_requestsChannel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/volunteerhomebg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 100),
            Text(
              'Help a\nsenior out!',
              textAlign: TextAlign.center,
              style: primaryh2TextStyle.copyWith(
                color: AppColors.lighterOrange,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'In Tappole, you can help out seniors with digital tasks such as recovering accidentally deleted photos, checking emails and more.',
                style: primarypTextStyle.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'All Requests',
                    style: primarypTextStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAscending = !_isAscending;
                        _refreshRequests();
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.list, color: Colors.white),
                        const SizedBox(width: 6),
                        Icon(
                          _isAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            Expanded(
              child: FutureBuilder<List<Request>>(
                future: _pendingRequestsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No pending requests found.',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }

                  final List<Request> requests = snapshot.data!;

                  return RefreshIndicator(
                    onRefresh: _refreshRequests,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20, top: 0),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        return _buildRequestCard(context, requests[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Request request) {
    return GestureDetector(
      onTap: () => _showRequestDetailsDialog(context, request),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), // Space between cards
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // Matches the rounded look
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: _profileService.getPublicUserInfo(request.requested_by),
              builder: (context, snapshot) {
                String name = "Senior";
                ImageProvider avatar = const AssetImage(
                  'assets/images/user_avatar.png',
                );

                if (snapshot.hasData && snapshot.data != null) {
                  final data = snapshot.data!;
                  name = "${data['first_name']} ${data['last_name']}";
                  if (data['profile_picture'] != null) {
                    avatar = NetworkImage(data['profile_picture']!);
                  }
                }

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: avatar,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Archivo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF192133),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            Text(
              request.req_content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: primarypTextStyle.copyWith(
                fontSize: 14,
                color: const Color(0xFF535763),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // "Pending" Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFFFC525,
                    ), // The Yellow Color from design
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "Pending",
                    style: TextStyle(
                      fontFamily: 'Archivo',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF192133), // Dark text on yellow
                    ),
                  ),
                ),

                // Timestamp
                Text(
                  // Simple trim or use DateFormat('d/M/yy HH:mm').format(request.created_at)
                  request.created_at.toString().substring(0, 16),
                  style: const TextStyle(
                    fontFamily: 'Archivo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF192133),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestDetailsDialog(BuildContext context, Request request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: _profileService.getPublicUserInfo(request.requested_by),
                builder: (context, snapshot) {
                  String name = "Loading...";
                  if (snapshot.hasData && snapshot.data != null) {
                    name =
                        "${snapshot.data!['first_name']} ${snapshot.data!['last_name']}";
                  }
                  return Text(
                    name,
                    style: primaryh2TextStyle.copyWith(fontSize: 18),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                "Posted: ${request.created_at.toString().substring(0, 16)}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Text(
                request.req_content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF535763),
                ),
              ),
              const SizedBox(height: 30),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: primarypTextStyle.copyWith(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      textStyle: lightpTextStyle,
                      text: "Accept and Help",
                      onPressed: () async {
                        await _requestService.acceptRequestAndStartCall(
                          request.req_id,
                        );

                        if (context.mounted) {
                          final currentUser =
                              Supabase.instance.client.auth.currentUser!;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VideoCallPage(
                                callId: request.req_id,
                                userId: currentUser.id,
                                userName: "Volunteer",
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

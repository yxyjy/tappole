import 'package:flutter/material.dart';
import '../../services/request_service.dart';
import '../../models/request.dart';
import '../../theme/app_styles.dart';
import '../../theme/app_colors.dart';

class VolunteerHomePage extends StatefulWidget {
  const VolunteerHomePage({super.key});

  @override
  _VolunteerHomePageState createState() => _VolunteerHomePageState();
}

class _VolunteerHomePageState extends State<VolunteerHomePage> {
  late final RequestService _requestService;
  late Future<List<Request>> _pendingRequestsFuture;

  @override
  void initState() {
    super.initState();
    _requestService = RequestService();
    // Assuming you implemented this method in the previous step
    _pendingRequestsFuture = _requestService.getPendingRequestsForVolunteers();
  }

  Future<void> _refreshRequests() async {
    setState(() {
      _pendingRequestsFuture = _requestService
          .getPendingRequestsForVolunteers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Reduced side padding slightly to give the grid more room
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
            const SizedBox(height: 120),
            Text(
              'Help a senior out!',
              textAlign: TextAlign.center,
              style: primaryh2TextStyle.copyWith(
                color: AppColors.lighterOrange,
              ), // Using your existing style
            ),
            const SizedBox(height: 20),
            Text(
              'In Tappole, you can help out seniors with digital tasks such as recovering accidentally deleted photos, checking emails and more.',
              style: primarypTextStyle.copyWith(
                color: AppColors.white,
              ), // Using your existing style
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: FutureBuilder<List<Request>>(
                future: _pendingRequestsFuture,
                builder: (context, snapshot) {
                  // A. Handle Loading State
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
                    return Center(
                      child: Text(
                        'No pending requests found.',
                        style: primaryh2TextStyle.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    );
                  }

                  final List<Request> requests = snapshot.data!;

                  // 💡 CHANGE: Using GridView instead of ListView
                  return RefreshIndicator(
                    onRefresh: _refreshRequests,
                    child: GridView.builder(
                      padding: const EdgeInsets.only(bottom: 20, top: 10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing:
                                15, // Horizontal space between cards
                            mainAxisSpacing: 15, // Vertical space between cards
                            childAspectRatio: 0.85, // Ratio of Width / Height
                          ),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final Request request = requests[index];
                        return _buildGridRequestCard(context, request);
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

  Widget _buildGridRequestCard(BuildContext context, Request request) {
    final String status = request.req_status;

    Color badgeColor = const Color(0xFFFFC525); // Default yellow for pending

    if (status == 'pending') {
      badgeColor = const Color(0xFFFFC525);
    }

    return GestureDetector(
      onTap: () {
        // Re-use your existing dialog logic here if needed
        _showRequestDetailsDialog(context, request, badgeColor);
      },
      child: Card(
        elevation: 5.0,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: Avatar and Name
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20.0, // Slightly smaller to fit grid
                    backgroundColor: Color(0xFFF0F0F0),
                    // TODO: Use actual user image if available in a join query
                    backgroundImage: AssetImage(
                      'assets/images/user_avatar.png',
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      request.senior_name ?? 'Senior User',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF192133),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Archivo',
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),

              // 2. Body: Request Content (The main text)
              Expanded(
                child: Text(
                  request.req_content, // Actual content from database
                  maxLines: 4, // Limit lines for grid consistency
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF192133),
                    fontFamily: 'Archivo',
                    fontWeight:
                        FontWeight.w300, // Lighter font weight as per design
                    fontSize: 14.0,
                    height: 1.3,
                  ),
                ),
              ),

              const SizedBox(height: 16.0),

              // 3. Footer: Date
              Text(
                // Format: 28/7/25 00:00 (You can use intl package for exact formatting)
                request.created_at.toString().substring(0, 16),
                style: const TextStyle(
                  color: Color(0xFF192133),
                  fontFamily: 'Archivo',
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestDetailsDialog(
    BuildContext context,
    Request request,
    Color badgeColor,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shadowColor: const Color.fromARGB(46, 25, 33, 51),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            request.req_title ?? 'Request Details',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Archivo',
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  request.created_at.toString().substring(0, 16),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 15),
                Text(
                  request.req_content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Archivo',
                    color: Color(0xFF192133),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            // Example "Accept" button for volunteers
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF06638),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // TODO: Call acceptRequest service here
                Navigator.of(context).pop();
              },
              child: const Text(
                'Accept',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/request_service.dart';
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
            const SizedBox(height: 80),
            Text(
              'Accepted Requests',
              textAlign: TextAlign.center,
              style: primaryh2TextStyle.copyWith(
                color: AppColors.primaryOrange,
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

  Widget _buildRequestCard(BuildContext context, Request request) {
    final String status = request.req_status;
    Color backgroundColor;
    Color statusTextColor = Colors.white;

    switch (status) {
      case 'pending':
        backgroundColor = const Color(0xFFFFC525);
        statusTextColor = Colors.black;
        break;
      case 'completed':
        backgroundColor = const Color.fromARGB(255, 39, 181, 51);
        break;
      case 'cancelled':
        backgroundColor = const Color.fromARGB(255, 200, 73, 73);
        break;
      case 'accepted':
        backgroundColor = const Color(0xFFF06638);
        break;
      default:
        backgroundColor = Colors.grey;
    }

    return Card(
      shadowColor: const Color.fromARGB(110, 25, 33, 51),
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            title: Text(
              request.created_at.toString().substring(0, 16),
              style: primarypTextStyle,
            ),
            subtitle: Text(
              request.req_title ?? 'No Title',
              style: primarypTextStyle,
            ),
            trailing: const Icon(Icons.mode_edit_outline_rounded),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shadowColor: const Color.fromARGB(46, 25, 33, 51),
                    backgroundColor: Colors.white,
                    title: Text('00:00 12/12/12', style: primarypTextStyle),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(request.req_content, style: primarypTextStyle),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          status,
                          style: primarypTextStyle.copyWith(
                            color: statusTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                  );
                },
              );
            },
          ),

          const SizedBox(height: 6),

          Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                status.toUpperCase(),
                style: primarypTextStyle.copyWith(
                  color: statusTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Archivo',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

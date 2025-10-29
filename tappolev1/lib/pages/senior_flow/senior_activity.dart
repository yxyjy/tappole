import 'package:flutter/material.dart';
import '../../services/request_service.dart';
import '../../models/request.dart';
import '../../theme/app_styles.dart';

class SeniorActivityPage extends StatefulWidget {
  const SeniorActivityPage({super.key});

  MaterialPageRoute<void> get route {
    return MaterialPageRoute<void>(builder: (_) => const SeniorActivityPage());
  }

  @override
  _SeniorActivityPageState createState() => _SeniorActivityPageState();
}

class _SeniorActivityPageState extends State<SeniorActivityPage> {
  late final RequestService _requestService;
  late Future<List<Request>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestService = RequestService();
    _requestsFuture = _requestService.getRequestsBySenior();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/seniorhomebg.png'),
            fit: BoxFit.cover,
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 120),
            Text(
              'Your Requests',
              textAlign: TextAlign.center,
              style: primaryh2TextStyle,
            ),
            const SizedBox(height: 20),
            Text(
              'Edit your active requests or view your previous requests.',
              style: primarypTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: FutureBuilder<List<Request>>(
                future: _requestsFuture,
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
                    return const Center(
                      child: Text(
                        'You have no requests yet.',
                        style: TextStyle(color: Color(0xFF192133)),
                      ),
                    );
                  }

                  final List<Request> requests = snapshot.data!;

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final Request request = requests[index];
                      return _buildRequestCard(
                        context,
                        request,
                      ); // Use a dedicated builder function
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

//             Expanded(
//               child: ListView.builder(
//                 itemCount: 20, // Placeholder for the number of items
//                 itemBuilder: (context, index) {
//                   // 1. Determine the status and colors (same logic as before)
//                   final String status = index % 3 == 0
//                       ? 'Completed'
//                       : index % 3 == 1
//                       ? 'Pending'
//                       : 'Cancelled';

//                   Color backgroundColor;
//                   switch (status) {
//                     case 'Pending':
//                       backgroundColor = const Color(0xFFFFC525); // Yellow
//                       break;
//                     case 'Completed':
//                       backgroundColor = const Color.fromARGB(
//                         255,
//                         39,
//                         181,
//                         51,
//                       ); // Green
//                       break;
//                     case 'Cancelled':
//                       backgroundColor = const Color.fromARGB(
//                         255,
//                         200,
//                         73,
//                         73,
//                       ); // Red
//                       break;
//                     default:
//                       backgroundColor = Colors.grey;
//                   }

//                   return Card(
//                     shadowColor: const Color.fromARGB(110, 25, 33, 51),
//                     elevation: 2,
//                     color: Colors.white,
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 8,
//                     ),
//                     // 2. The child of the Card is a Column
//                     child: Column(
//                       // Important: Align the Column's children to the start (left)
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min, // Keep the Column tight
//                       children: [
//                         // 3. The original ListTile is the first child
//                         ListTile(
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 10,
//                           ),
//                           title: Text(
//                             'Date/time',
//                             style: TextStyle(
//                               fontSize: 15,
//                               height: 1.05,
//                               fontFamily: 'Archivo',
//                               fontWeight: FontWeight.w100,
//                               color: const Color.fromARGB(110, 25, 33, 51),
//                             ),
//                           ), // Placeholder title
//                           subtitle: const Text(
//                             'Short description of the request...',
//                             style: TextStyle(
//                               fontSize: 15,
//                               height: 1.05,
//                               fontFamily: 'Archivo',
//                               fontWeight: FontWeight.w100,
//                               color: Color(0xFF192133),
//                             ),
//                           ), // Placeholder subtitle
//                           trailing: const Icon(Icons.mode_edit_outline_rounded),
//                           onTap: () {
//                             // Your existing showDialog logic (or Navigator push)
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   shadowColor: const Color.fromARGB(
//                                     46,
//                                     25,
//                                     33,
//                                     51,
//                                   ),
//                                   title: Text(
//                                     '00:00 12/12/12',
//                                     style: TextStyle(
//                                       fontSize: 15,
//                                       height: 1.05,
//                                       fontFamily: 'Archivo',
//                                       fontWeight: FontWeight.w100,
//                                       color: const Color.fromARGB(
//                                         110,
//                                         25,
//                                         33,
//                                         51,
//                                       ),
//                                     ),
//                                   ),
//                                   content: SingleChildScrollView(
//                                     child: ListBody(
//                                       children: <Widget>[
//                                         const Text(
//                                           'This is the full, detailed description of the request.',
//                                         ),
//                                         const SizedBox(height: 10),
//                                       ],
//                                     ),
//                                   ),
//                                   actions: <Widget>[
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 8,
//                                         vertical: 4,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: backgroundColor,
//                                         borderRadius: BorderRadius.circular(
//                                           4.0,
//                                         ), // Rounded badge corners
//                                       ),
//                                       child: Text(
//                                         status,
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: 'Archivo',
//                                         ),
//                                       ),
//                                     ),

//                                     TextButton(
//                                       child: const Text('Close'),
//                                       onPressed: () {
//                                         Navigator.of(context).pop();
//                                       },
//                                     ),
//                                   ],
//                                   actionsAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                 );
//                               },
//                             );
//                           },
//                         ),

//                         // 4. A separator space below the ListTile (if needed)
//                         // Note: The Listtile's vertical padding may make this unnecessary,
//                         // but we'll add a small space for control.
//                         const SizedBox(height: 6),

//                         // 5. The Status Badge
//                         Padding(
//                           // Match the horizontal padding of the ListTile
//                           padding: const EdgeInsets.only(
//                             left: 10.0,
//                             bottom: 10.0,
//                           ),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: backgroundColor,
//                               borderRadius: BorderRadius.circular(
//                                 4.0,
//                               ), // Rounded badge corners
//                             ),
//                             child: Text(
//                               status,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: 'Archivo',
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

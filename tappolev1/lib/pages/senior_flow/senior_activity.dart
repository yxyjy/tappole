import 'package:flutter/material.dart';

class SeniorActivityPage extends StatefulWidget {
  const SeniorActivityPage({super.key});
  @override
  _SeniorActivityPageState createState() => _SeniorActivityPageState();
}

class _SeniorActivityPageState extends State<SeniorActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
            const Text(
              'Your Requests',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.0,
                color: Color(0xFF192133),
                fontSize: 36,
                fontFamily: 'Archivo',
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Edit your active requests or view your previous requests.',
              style: TextStyle(
                fontSize: 15,
                height: 1.05,
                fontFamily: 'Archivo',
                fontWeight: FontWeight.w300,
                color: Color(0xFF192133),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 20, // Placeholder for the number of items
                itemBuilder: (context, index) {
                  // 1. Determine the status and colors (same logic as before)
                  final String status = index % 3 == 0
                      ? 'Completed'
                      : index % 3 == 1
                      ? 'Pending'
                      : 'Cancelled';

                  Color backgroundColor;
                  switch (status) {
                    case 'Pending':
                      backgroundColor = const Color(0xFFFFC525); // Yellow
                      break;
                    case 'Completed':
                      backgroundColor = const Color.fromARGB(
                        255,
                        39,
                        181,
                        51,
                      ); // Green
                      break;
                    case 'Cancelled':
                      backgroundColor = const Color.fromARGB(
                        255,
                        200,
                        73,
                        73,
                      ); // Red
                      break;
                    default:
                      backgroundColor = Colors.grey;
                  }

                  return Card(
                    shadowColor: const Color.fromARGB(110, 25, 33, 51),
                    elevation: 2,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    // 2. The child of the Card is a Column
                    child: Column(
                      // Important: Align the Column's children to the start (left)
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Keep the Column tight
                      children: [
                        // 3. The original ListTile is the first child
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          title: Text(
                            'Date/time',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.05,
                              fontFamily: 'Archivo',
                              fontWeight: FontWeight.w100,
                              color: const Color.fromARGB(110, 25, 33, 51),
                            ),
                          ), // Placeholder title
                          subtitle: const Text(
                            'Short description of the request...',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.05,
                              fontFamily: 'Archivo',
                              fontWeight: FontWeight.w100,
                              color: Color(0xFF192133),
                            ),
                          ), // Placeholder subtitle
                          trailing: const Icon(Icons.mode_edit_outline_rounded),
                          onTap: () {
                            // Your existing showDialog logic (or Navigator push)
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shadowColor: const Color.fromARGB(
                                    46,
                                    25,
                                    33,
                                    51,
                                  ),
                                  title: Text(
                                    '00:00 12/12/12',
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.05,
                                      fontFamily: 'Archivo',
                                      fontWeight: FontWeight.w100,
                                      color: const Color.fromARGB(
                                        110,
                                        25,
                                        33,
                                        51,
                                      ),
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        const Text(
                                          'This is the full, detailed description of the request.',
                                        ),
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
                                        borderRadius: BorderRadius.circular(
                                          4.0,
                                        ), // Rounded badge corners
                                      ),
                                      child: Text(
                                        status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Archivo',
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
                                  actionsAlignment:
                                      MainAxisAlignment.spaceBetween,
                                );
                              },
                            );
                          },
                        ),

                        // 4. A separator space below the ListTile (if needed)
                        // Note: The Listtile's vertical padding may make this unnecessary,
                        // but we'll add a small space for control.
                        const SizedBox(height: 6),

                        // 5. The Status Badge
                        Padding(
                          // Match the horizontal padding of the ListTile
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            bottom: 10.0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(
                                4.0,
                              ), // Rounded badge corners
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

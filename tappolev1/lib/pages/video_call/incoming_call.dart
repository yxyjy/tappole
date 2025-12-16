import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tappolev1/components/primary_button.dart';
import 'video_call_page.dart';
import '../../theme/app_styles.dart';

class IncomingCallPage extends StatefulWidget {
  final String callId; // This is the request_id
  final String volunteerId; // We need this to fetch volunteer info
  final String currentUserId;

  const IncomingCallPage({
    super.key,
    required this.callId,
    required this.volunteerId,
    required this.currentUserId,
  });

  @override
  State<IncomingCallPage> createState() => _IncomingCallPageState();
}

class _IncomingCallPageState extends State<IncomingCallPage> {
  bool _isLoading = true;

  // Data to display
  String _volunteerName = "Volunteer";
  //String _volunteerDetails = ""; // e.g. "24, Speaks Mandarin"
  String _profilePicUrl = "";
  String _requestContent = "Loading request details...";
  String _requestDate = "";

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  // Fetch Volunteer Profile and Request Info
  Future<void> _fetchDetails() async {
    final supabase = Supabase.instance.client;

    try {
      final profileData = await supabase
          .from('profiles')
          .select()
          .eq('id', widget.volunteerId)
          .single();

      final requestData = await supabase
          .from('requests')
          .select()
          .eq('req_id', widget.callId)
          .single();

      if (mounted) {
        setState(() {
          _volunteerName =
              "${profileData['first_name']} ${profileData['last_name']}";
          _profilePicUrl = profileData['profile_picture'] ?? "";

          // Calculate Age (Optional logic)
          // String age = "";
          // if (profileData['dob'] != null) {
          //   final dob = DateTime.parse(profileData['dob']);
          //   final years = DateTime.now().difference(dob).inDays ~/ 365;
          //   age = "$years, ";
          // }
          // Assuming you have a 'languages' or 'bio' column, otherwise hardcode or leave blank
          // _volunteerDetails =
          //     "$age${profileData['languages'] ?? 'Ready to help'}";

          // Request Info
          _requestContent = requestData['req_content'];
          _requestDate = requestData['created_at'].toString().substring(0, 16);

          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching details: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFFEBD0); // Light Peach
    const cardColor = Color(0xFF192133); // Dark Navy
    const btnColor = Color(0xFFF06638); // Orange

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/seniorhomebg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 80,
                          horizontal: 50,
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Someone’s ready to help you!",
                              style: primaryh2TextStyle.copyWith(fontSize: 32),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height:
                            MediaQuery.of(context).size.height *
                            0.65, // Takes up bottom 65%
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 100,
                            ), // Space for Avatar overlap
                            // Name
                            Text(
                              _volunteerName,
                              style: lighth2TextStyle.copyWith(fontSize: 24),
                            ),

                            // const SizedBox(height: 5),
                            // Details (Age, Language)
                            // Text(
                            //   _volunteerDetails,
                            //   style: const TextStyle(
                            //     fontFamily: 'Archivo',
                            //     fontSize: 16,
                            //     color: Colors.white70,
                            //     fontWeight: FontWeight.w500,
                            //   ),
                            // ),
                            const SizedBox(height: 30),

                            // --- WHITE REQUEST CARD ---
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date & Icon
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _requestDate,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // const Icon(
                                      //   Icons.edit_note,
                                      //   size: 20,
                                      //   color: cardColor,
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Content
                                  Text(
                                    _requestContent,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: primarypTextStyle,
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFC525), // Yellow
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Accepted",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: cardColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 80),

                            Padding(
                              padding: const EdgeInsets.only(bottom: 40),
                              child: SizedBox(
                                width: 200,
                                height: 55,
                                child: PrimaryButton(
                                  text: "Accept Call",
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                    // Navigator.pushReplacement(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (_) => VideoCallPage(
                                    //       callId: widget.callId,
                                    //       userId: widget.currentUserId,
                                    //       userName: "Senior",
                                    //     ),
                                    //   ),
                                    // );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- FLOATING AVATAR ---
                    // We position this using a calculation based on the card height
                    Positioned(
                      bottom:
                          (MediaQuery.of(context).size.height * 0.65) -
                          60, // Card Height - half avatar size
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cardColor,
                              width: 4,
                            ), // Border matches card color
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _profilePicUrl.isNotEmpty
                                ? NetworkImage(_profilePicUrl)
                                : const AssetImage(
                                        'assets/images/user_avatar.png',
                                      )
                                      as ImageProvider,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

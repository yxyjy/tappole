import 'package:flutter/material.dart';
import '../../services/request_service.dart';
import '../../services/profile_service.dart';
import '../../models/request.dart';
import '../../models/profile.dart';
import '../../theme/app_styles.dart';
import '../../theme/app_colors.dart';
import '../../components/primary_button.dart';
import '../../components/styled_snackbar.dart';

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
  final ProfileService _profileService = ProfileService();
  late Future<List<Request>> _requestsFuture;
  late Future<UserProfile> _profileFuture;

  bool _isAscending = false;

  String _selectedStatus = 'All';
  final List<String> _filterOptions = [
    'All',
    'Pending',
    'Accepted',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _requestService = RequestService();
    _requestsFuture = _requestService.getRequestsBySenior(
      isAscending: _isAscending,
    );
    _profileFuture = _profileService.getProfile();
    _fetchRequests();
  }

  void _fetchRequests() {
    setState(() {
      _requestsFuture = _requestService.getRequestsBySenior(
        isAscending: _isAscending,
        status: _selectedStatus, // Pass the filter here
      );
    });
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
            image: AssetImage('assets/images/seniorhomebg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 90),
            Text(
              'Your\nRequests',
              textAlign: TextAlign.center,
              style: primaryh2TextStyle,
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Edit your active requests or view your previous requests.',
                style: primarypTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            //requests sorter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'All Previous Requests',
                    style: primarypTextStyle.copyWith(),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAscending = !_isAscending;
                        _fetchRequests();
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.list, color: AppColors.primaryOrange),
                        const SizedBox(width: 6),
                        Icon(
                          _isAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: AppColors.primaryOrange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((status) {
                  final bool isSelected = _selectedStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: Colors.white,
                      labelStyle: primarypTextStyle.copyWith(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryOrange
                              : Colors.grey.shade300,
                        ),
                      ),

                      onSelected: (bool selected) {
                        if (selected) {
                          _selectedStatus = status;
                          _fetchRequests();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 15),

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
                        return Center(
                          child: Text(
                            'You have no requests yet.',
                            style: primarypTextStyle,
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
                            userProfile,
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

    switch (status) {
      case 'pending':
        statusBgColor = AppColors.warningOrange;
        statusTextColor = Colors.white;
        break;
      case 'accepted':
        statusBgColor = AppColors.successGreen;
        statusTextColor = Colors.white;
        break;
      case 'completed':
        statusBgColor = AppColors.infoBlue;
        statusTextColor = Colors.white;
        break;
      case 'cancelled':
        statusBgColor = AppColors.cancelledGrey;
        break;
      default:
        statusBgColor = const Color.fromARGB(255, 255, 255, 255);
    }

    ImageProvider avatarImage;
    if (profile.profilePictureUrl != null &&
        profile.profilePictureUrl!.isNotEmpty) {
      avatarImage = NetworkImage(profile.profilePictureUrl!);
    } else {
      avatarImage = const AssetImage('assets/images/user_avatar.png');
    }

    return Card(
      elevation: 0.5,
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

    Color statusBgColor;
    Color statusTextColor = AppColors.primaryDarkBlue;

    switch (status) {
      case 'pending':
        statusBgColor = AppColors.warningOrange;
        break;
      case 'accepted':
        statusBgColor = AppColors.successGreen;
        statusTextColor = Colors.white;
        break;
      case 'completed':
        statusBgColor = AppColors.infoBlue;
        statusTextColor = Colors.white;
        break;
      case 'cancelled':
        statusBgColor = AppColors.cancelledGrey;
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.created_at.toString().substring(0, 16),
                    style: primarypTextStyle,
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
                      style: primarypTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(request.req_content, style: primarypTextStyle),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              if (status == 'pending')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        backgroundColor: Colors.white,
                        border: BorderSide(
                          color: const Color.fromARGB(255, 119, 119, 119),
                          width: 1.2,
                        ),
                        textColor: const Color.fromARGB(255, 119, 119, 119),
                        boxDecoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                255,
                                171,
                                171,
                                171,
                              ).withAlpha(0),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        onPressed: () {
                          _showConfirmCancelDialog(context, request);
                        },
                        text: "Cancel Request",
                      ),
                    ),
                    SizedBox(width: 10),

                    Expanded(
                      flex: 1,
                      child: PrimaryButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditDialog(context, request);
                        },
                        text: "Edit",
                      ),
                    ),
                  ],
                )
              else
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Close",
                    style: primarypTextStyle.copyWith(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Request request) {
    final TextEditingController controller = TextEditingController(
      text: request.req_content,
    );
    bool _isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Edit Request",
                style: primarypTextStyle.copyWith(fontSize: 20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: primarypTextStyle,
                    controller: controller,
                    maxLines: 5,
                    minLines: 3,
                    decoration: primaryInputDecoration.copyWith(
                      hintText: "Update your request details here...",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  if (_isUpdating) ...[
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isUpdating ? null : () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: primarypTextStyle.copyWith(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF06638),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: primarypTextStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _isUpdating
                      ? null
                      : () async {
                          if (controller.text.trim().isEmpty) return;

                          setState(() => _isUpdating = true); // Show loading

                          try {
                            // 1. Call Service
                            await _requestService.updateRequestContent(
                              request.req_id,
                              controller.text.trim(),
                            );

                            if (context.mounted) {
                              Navigator.pop(context);

                              this.setState(() {
                                _requestsFuture = _requestService
                                    .getRequestsBySenior();
                              });

                              StyledSnackbar.show(
                                context: context,
                                message: "Request updated successfully!",
                                type: SnackbarType.success,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setState(() => _isUpdating = false);
                              StyledSnackbar.show(
                                context: context,
                                message: "Failed to update: $e",
                                type: SnackbarType.error,
                              );
                            }
                          }
                        },

                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfirmCancelDialog(BuildContext context, Request request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Confirm Cancel",
          style: primarypTextStyle.copyWith(fontSize: 20),
        ),
        content: Text(
          "Are you sure you want to cancel this request?",
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
          TextButton(
            onPressed: () async {
              try {
                await _requestService.cancelRequest(request.req_id);

                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                  setState(() {
                    _requestsFuture = _requestService.getRequestsBySenior();
                  });

                  StyledSnackbar.show(
                    context: context,
                    message: "Request cancelled successfully",
                    type: SnackbarType.success,
                  );
                }
              } catch (e) {
                print("Cancel Error: $e");
                if (context.mounted) {
                  Navigator.pop(context);
                  StyledSnackbar.show(
                    context: context,
                    message: "Failed to cancel: $e",
                    type: SnackbarType.error,
                  );
                }
              }
            },
            child: Text(
              "Yes, Cancel",
              style: primarypTextStyle.copyWith(
                color: AppColors.errorOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io'; // Required for File
import 'package:flutter/material.dart'; // Required for picking images
import 'package:tappolev1/components/primary_button.dart';
import 'package:tappolev1/services/profile_service.dart';
import 'package:tappolev1/models/profile.dart';
import 'package:tappolev1/theme/app_styles.dart';
import 'package:tappolev1/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile initialProfile;

  const EditProfilePage({super.key, required this.initialProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // State Variables
  late DateTime _selectedDob;
  late String _selectedGender;

  // Image Picking State
  XFile? _pickedImageFile; // Stores the file locally if user picks a new one
  final ImagePicker _picker = ImagePicker();

  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing data
    _firstNameController.text = widget.initialProfile.firstName;
    _lastNameController.text = widget.initialProfile.lastName;
    _phoneController.text = widget.initialProfile.phone;
    _selectedDob = widget.initialProfile.dob;
    _selectedGender = widget.initialProfile.gender.toLowerCase();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress slightly to save data
      );

      if (image != null) {
        setState(() {
          _pickedImageFile = image;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  // --- 2. Updated Save Function ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? finalAvatarUrl = widget.initialProfile.profilePictureUrl;

      if (_pickedImageFile != null) {
        final uploadedUrl = await _profileService.uploadAvatar(
          _pickedImageFile!,
          widget.initialProfile.id,
        );

        if (uploadedUrl != null) {
          finalAvatarUrl = uploadedUrl;
        }
      }

      final updatedProfile = UserProfile(
        id: widget.initialProfile.id,
        role: widget.initialProfile.role,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        dob: _selectedDob,
        gender: _selectedGender,
        profilePictureUrl: finalAvatarUrl,
      );

      await _profileService.updateProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which image provider to use for the avatar
    ImageProvider? backgroundImage;

    if (_pickedImageFile != null) {
      if (kIsWeb) {
        // Web: Use NetworkImage with the temporary blob path
        backgroundImage = NetworkImage(_pickedImageFile!.path);
      } else {
        // Mobile: Use FileImage
        backgroundImage = FileImage(File(_pickedImageFile!.path));
      }
    } else if (widget.initialProfile.profilePictureUrl != null &&
        widget.initialProfile.profilePictureUrl!.isNotEmpty) {
      backgroundImage = NetworkImage(widget.initialProfile.profilePictureUrl!);
    } else {
      backgroundImage = const AssetImage('assets/images/user_avatar.png');
    }

    final editedPrimaryInputDecoration = primaryInputDecoration.copyWith(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 0.0,
        horizontal: 16.0,
      ),
    );
    final editedPrimaryInputTextStyle = primaryInputLabelTextStyle.copyWith(
      fontSize: 13.0,
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/profilebg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // --- WHITE CARD CONTAINER ---
            Positioned.fill(
              top: 120,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.lowerAlphaDarkBlue,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 100.0, // Space for the avatar overlapping top
                    left: 22.0,
                    right: 22.0,
                    bottom: 30.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Edit Profile',
                          textAlign: TextAlign.center,
                          style: primaryh2TextStyle.copyWith(fontSize: 32),
                        ),
                        const SizedBox(height: 30),

                        // First Name
                        TextFormField(
                          style: editedPrimaryInputTextStyle,
                          controller: _firstNameController,
                          decoration: editedPrimaryInputDecoration.copyWith(
                            labelText: 'First Name',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(
                                color: AppColors.lowerAlphaDarkBlue,
                                width: 1.0,
                              ),
                            ),
                          ),
                          validator: (value) => value!.trim().isEmpty
                              ? 'Enter your first name.'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Last Name
                        TextFormField(
                          style: editedPrimaryInputTextStyle,
                          controller: _lastNameController,
                          decoration: editedPrimaryInputDecoration.copyWith(
                            labelText: 'Last Name',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(
                                color: AppColors.lowerAlphaDarkBlue,
                                width: 1.0,
                              ),
                            ),
                          ),
                          validator: (value) => value!.trim().isEmpty
                              ? 'Enter your last name.'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        TextFormField(
                          style: editedPrimaryInputTextStyle,
                          controller: _phoneController,
                          decoration: editedPrimaryInputDecoration.copyWith(
                            labelText: 'Phone Number',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(
                                color: AppColors.lowerAlphaDarkBlue,
                                width: 1.0,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value!.trim().length < 8
                              ? 'Enter a valid phone number.'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // DOB & Gender Row
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: GestureDetector(
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: editedPrimaryInputDecoration
                                      .copyWith(
                                        labelText: 'Date of Birth',
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20.0,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.lowerAlphaDarkBlue,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                  child: Text(
                                    '${_selectedDob.day}/${_selectedDob.month}/${_selectedDob.year}',
                                    style: editedPrimaryInputTextStyle,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 6,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _selectedGender,
                                decoration: editedPrimaryInputDecoration
                                    .copyWith(
                                      labelText: 'Gender',
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                        borderSide: const BorderSide(
                                          color: AppColors.lowerAlphaDarkBlue,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                items:
                                    [
                                          'male',
                                          'female',
                                          'other',
                                          'prefer_not_to_say',
                                        ]
                                        .map(
                                          (value) => DropdownMenuItem(
                                            value: value,
                                            child: Text(
                                              overflow: TextOverflow.ellipsis,
                                              value
                                                  .replaceAll('_', ' ')
                                                  .toUpperCase(),
                                              style:
                                                  editedPrimaryInputTextStyle,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (newValue) =>
                                    setState(() => _selectedGender = newValue!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : PrimaryButton(
                                text: 'Save Changes',
                                onPressed: _saveProfile,
                              ),
                        const SizedBox(height: 16),

                        // Cancel Button
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: primaryLinkTextStyle.copyWith(
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // //settings button
            // Positioned(
            //   top: MediaQuery.of(context).padding.top + 10,
            //   left: 10,
            //   child: TextButton.icon(
            //     onPressed: () {},
            //     icon: const Icon(Icons.settings, color: Colors.white),
            //     label: const Text('Settings', style: TextStyle(color: Colors.white)),
            //   ),
            // ),

            // // close button
            // Positioned(
            //   top: MediaQuery.of(context).padding.top + 10,
            //   right: 10,
            //   child: IconButton(
            //     icon: const Icon(Icons.close, color: Colors.white, size: 30),
            //     onPressed: () => Navigator.of(context).pop(),
            //   ),
            // ),
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 150,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          border: Border.all(color: AppColors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.lowerAlphaDarkBlue,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                          image: DecorationImage(
                            image: backgroundImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // The "Edit" Camera Icon Overlay
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryOrange, // Uses your app color
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tappolev1/components/primary_button.dart'; // Assumed
import 'package:tappolev1/services/profile_service.dart';
import 'package:tappolev1/models/profile.dart';
import 'package:tappolev1/theme/app_styles.dart';
import 'package:tappolev1/theme/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile initialProfile;

  const EditProfilePage({super.key, required this.initialProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers and State from your original EditProfilePage
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  late DateTime _selectedDob;
  late String _selectedGender;

  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the profile data
    _firstNameController.text = widget.initialProfile.firstName;
    _lastNameController.text = widget.initialProfile.lastName;
    _phoneController.text = widget.initialProfile.phone;
    _selectedDob = widget.initialProfile.dob;
    _selectedGender = widget.initialProfile.gender
        .toLowerCase(); // Use lowercase for dropdown
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Don't submit if form is invalid
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedProfile = UserProfile(
        id: widget.initialProfile.id,
        role: widget.initialProfile.role, // Role is not editable here
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        dob: _selectedDob,
        gender: _selectedGender,
      );

      await _profileService.updateProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop(); // Go back to the profile page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            image: AssetImage('assets/images/profilebg.png'), // Background
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              top: 100,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lowerAlphaDarkBlue,
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 115.0,
                    left: 22.0,
                    right: 22.0,
                    bottom: 30.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Text(
                          'Edit Profile',
                          textAlign: TextAlign.center,
                          style: primaryh2TextStyle.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 30),

                        TextFormField(
                          style: editedPrimaryInputTextStyle,
                          controller: _firstNameController,
                          decoration: editedPrimaryInputDecoration.copyWith(
                            labelText: 'First Name',
                          ),
                          validator: (value) => value!.trim().isEmpty
                              ? 'Enter your first name.'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          style: editedPrimaryInputTextStyle,
                          controller: _lastNameController,
                          decoration: editedPrimaryInputDecoration.copyWith(
                            labelText: 'Last Name',
                          ),
                          validator: (value) => value!.trim().isEmpty
                              ? 'Enter your last name.'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          style: editedPrimaryInputTextStyle,
                          controller: _phoneController,
                          decoration: editedPrimaryInputDecoration.copyWith(
                            labelText: 'Phone Number',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value!.trim().length < 8
                              ? 'Enter a valid phone number.'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: editedPrimaryInputDecoration
                                      .copyWith(labelText: 'Date of Birth'),
                                  child: Text(
                                    style: editedPrimaryInputTextStyle,
                                    '${_selectedDob.day}/${_selectedDob.month}/${_selectedDob.year}',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: editedPrimaryInputDecoration
                                    .copyWith(labelText: 'Gender'),
                                items:
                                    [
                                          'male',
                                          'female',
                                          'other',
                                          'prefer_not_to_say',
                                        ]
                                        .map(
                                          (
                                            String value,
                                          ) => DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              style:
                                                  editedPrimaryInputTextStyle,
                                              value
                                                  .replaceAll('_', ' ')
                                                  .toUpperCase(),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedGender = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Save Button
                        PrimaryButton(
                          text: 'Save Changes',
                          onPressed: _saveProfile,
                        ),
                        const SizedBox(height: 16),

                        // Cancel Button
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Go back
                          },
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

            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: TextButton.icon(
                onPressed: () {
                  /* Handle Settings navigation */
                },
                icon: const Icon(Icons.settings, color: Colors.white),
                label: const Text(
                  'Settings',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 130,
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
                    image: const DecorationImage(
                      image: AssetImage('assets/images/user_avatar.png'),
                      fit: BoxFit.cover,
                    ),
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

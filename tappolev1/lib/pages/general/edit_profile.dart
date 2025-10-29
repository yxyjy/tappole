import 'package:flutter/material.dart';
import 'package:tappolev1/components/primary_button.dart';
import 'package:tappolev1/services/profile_service.dart';
import 'package:tappolev1/models/profile.dart';
import 'package:tappolev1/theme/app_styles.dart'; // For primaryInputDecoration, etc.

class EditProfilePage extends StatefulWidget {
  final UserProfile initialProfile;

  const EditProfilePage({super.key, required this.initialProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers for text input fields
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // State variables for Date and Gender selection
  late DateTime _selectedDob;
  late String _selectedGender;

  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and state with the data passed from the profile page
    _firstNameController.text = widget.initialProfile.firstName;
    _lastNameController.text = widget.initialProfile.lastName;
    _phoneController.text = widget.initialProfile.phone;
    _selectedDob = widget.initialProfile.dob;
    _selectedGender = widget.initialProfile.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- Form Logic ---

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
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Create the updated profile object
      final updatedProfile = UserProfile(
        id: widget.initialProfile.id,
        role: widget.initialProfile.role, // Role cannot be changed here
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        dob: _selectedDob,
        gender: _selectedGender,
      );

      // 2. Call the service to update the database
      await _profileService.updateProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        // 3. Navigate back to the ProfilePage
        // Use pushReplacement to clear the stack if necessary, or just pop
        Navigator.of(context).pop();
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

  // --- UI Build ---

  @override
  Widget build(BuildContext context) {
    // You'd typically use a custom AppBar/Header here
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF192133),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First Name Field
              TextFormField(
                controller: _firstNameController,
                decoration: primaryInputDecoration.copyWith(
                  labelText: 'First Name',
                ),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Enter your first name.' : null,
              ),
              const SizedBox(height: 16),

              // Last Name Field
              TextFormField(
                controller: _lastNameController,
                decoration: primaryInputDecoration.copyWith(
                  labelText: 'Last Name',
                ),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Enter your last name.' : null,
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: primaryInputDecoration.copyWith(
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.trim().length < 8
                    ? 'Enter a valid phone number.'
                    : null,
              ),
              const SizedBox(height: 16),

              // Date of Birth Selector
              GestureDetector(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: primaryInputDecoration.copyWith(
                    labelText: 'Date of Birth',
                  ),
                  child: Text(
                    '${_selectedDob.day}/${_selectedDob.month}/${_selectedDob.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: primaryInputDecoration.copyWith(
                  labelText: 'Gender',
                ),
                items:
                    [
                          'male',
                          'female',
                          'other',
                          'prefer_not_to_say',
                        ] // Define your actual list of genders
                        .map(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.toUpperCase()),
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
              const SizedBox(height: 40),

              // Save Button (PrimaryButton Component)
              PrimaryButton(text: 'Save Changes', onPressed: _saveProfile),
              const SizedBox(height: 16),

              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Go back without saving
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
    );
  }
}

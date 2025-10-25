import 'package:flutter/material.dart';
import 'package:tappolev1/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

enum SignupSteps { roleSelection, emailPasswordEntry, userDetailsEntry }

class Signupflow extends StatefulWidget {
  const Signupflow({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const Signupflow());
  }

  @override
  State<Signupflow> createState() => _SignupflowState();
}

class _SignupflowState extends State<Signupflow> {
  SignupSteps _currentStep = SignupSteps.roleSelection;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final supabase = Supabase.instance.client;

  // --- State variables to hold data from all steps ---
  String _role = '';
  String _email = '';
  String _password = '';

  // --- Navigation Methods ---

  void _nextStep(SignupSteps step) {
    setState(() {
      _currentStep = step;
    });
  }

  // --- Data-handling Callbacks for Child Widgets ---

  /// Called from RoleSelectionStep
  void _onRoleSelected(String role) {
    setState(() {
      _role = role;
      _currentStep = SignupSteps.emailPasswordEntry;
    });
  }

  /// Called from SignupEmailPasswordStep
  void _onEmailPasswordSubmitted(String email, String password) async {
    setState(() {
      _email = email;
      _password = password;
      _currentStep = SignupSteps.userDetailsEntry;
    });
  }

  /// Called from UserDetailsStep (Final Step)
  void _onUserDetailsSubmitted(
    String firstName,
    String lastName,
    String phone,
    DateTime dob,
    String gender,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authResponse = await _authService.signUpWithEmailPassword(
        _email,
        _password,
      );

      if (authResponse.user == null) {
        throw const AuthException('Sign up failed. User could not be created.');
      }

      final userId = authResponse.user!.id;

      // 2. >>> Insert user details into the 'profiles' table <<<
      // We use all the data collected from the different steps
      await supabase.from('profiles').insert({
        'id': userId,
        'role': _role,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'dob': dob.toIso8601String(),
        'gender': gender,
      });

      if (!mounted) return;

      // 3. Show success and navigate back to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Success! Please check your email to verify your account.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(); // Go back to login
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Build Method (Conditional Rendering) ---

  @override
  Widget build(BuildContext context) {
    Widget currentWidget;

    switch (_currentStep) {
      case SignupSteps.roleSelection:
        currentWidget = RoleSelectionStep(onRoleSelected: _onRoleSelected);
        break;

      case SignupSteps.emailPasswordEntry:
        currentWidget = SignupEmailPasswordStep(
          onSubmitted: _onEmailPasswordSubmitted,
          onPrevious: () => _nextStep(SignupSteps.roleSelection),
        );
        break;

      case SignupSteps.userDetailsEntry:
        currentWidget = UserDetailsStep(
          onSubmitted: _onUserDetailsSubmitted,
          onPrevious: () => _nextStep(SignupSteps.emailPasswordEntry),
        );
        break;
    }

    return Scaffold(
      body: Stack(
        children: [
          currentWidget,
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(128),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ====================================================================
// --- STEP 2: ROLE SELECTION (New Widget)
// ====================================================================

class RoleSelectionStep extends StatelessWidget {
  final Function(String role) onRoleSelected;

  const RoleSelectionStep({super.key, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login2bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tell us who \nyou are',
              style: TextStyle(
                height: 1.0,
                color: Color(0xFF192133),
                fontSize: 44,
                fontFamily: 'Archivo',
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 30),
            const Text(
              'Please select your role to continue.',
              style: TextStyle(
                fontSize: 15,
                height: 1.05,
                fontFamily: 'Archivo',
                fontWeight: FontWeight.w300,
                color: Color(0xFF192133),
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 60),

            // --- "I am a Senior" Button ---
            _RoleButton(
              text: 'I am a Senior',
              onPressed: () => onRoleSelected('senior'),
            ),
            const SizedBox(height: 20),

            // --- "I am a Volunteer" Button ---
            _RoleButton(
              text: 'I am a Volunteer',
              onPressed: () => onRoleSelected('volunteer'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget for the role buttons to avoid code duplication
class _RoleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _RoleButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF06638).withAlpha(50),
            spreadRadius: 5,
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFF06638),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Archivo',
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// --- STEP 3: EMAIL & PASSWORD (New Widget)
// ====================================================================

class SignupEmailPasswordStep extends StatefulWidget {
  final Function(String email, String password) onSubmitted;
  final VoidCallback onPrevious;

  const SignupEmailPasswordStep({
    super.key,
    required this.onSubmitted,
    required this.onPrevious,
  });

  @override
  State<SignupEmailPasswordStep> createState() =>
      _SignupEmailPasswordStepState();
}

class _SignupEmailPasswordStepState extends State<SignupEmailPasswordStep> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _trySubmitForm() {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    // Pass data to parent
    widget.onSubmitted(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF192133)),
          onPressed: widget.onPrevious,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login2bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create your \nlogin',
                  style: TextStyle(
                    height: 1.0,
                    color: Color(0xFF192133),
                    fontSize: 44,
                    fontFamily: 'Archivo',
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 30),

                // --- Email ---
                TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration('Email Address'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // --- Password ---
                TextFormField(
                  controller: _passwordController,
                  decoration: _buildInputDecoration('Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return 'Password must be at least 6 characters long.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // --- Confirm Password ---
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: _buildInputDecoration('Confirm Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 80),

                // --- "Continue" Button ---
                _RoleButton(text: 'Continue', onPressed: _trySubmitForm),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for consistent styling
  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      fillColor: Colors.white,
      filled: true,
      enabledBorder: null,
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFF06638)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2.0),
      ),
      labelText: labelText,
      labelStyle: const TextStyle(
        color: Color(0x80192133),
        fontFamily: 'Archivo',
        fontWeight: FontWeight.w300,
      ),
    );
  }
}

// ====================================================================
// --- STEP 4: USER DETAILS (Modified SignupFormStep)
// ====================================================================

class UserDetailsStep extends StatefulWidget {
  final Function(
    String firstName,
    String lastName,
    String phone,
    DateTime dob,
    String gender,
  )
  onSubmitted;
  final VoidCallback onPrevious;

  const UserDetailsStep({
    super.key,
    required this.onSubmitted,
    required this.onPrevious,
  });

  @override
  State<UserDetailsStep> createState() => _UserDetailsStepState();
}

class _UserDetailsStepState extends State<UserDetailsStep> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _trySubmitForm() {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    widget.onSubmitted(
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      _phoneController.text.trim(),
      _selectedDate!,
      _selectedGender!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF192133)),
          onPressed: widget.onPrevious,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login2bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Tell us about \nyourself',
                  style: TextStyle(
                    height: 1.0,
                    color: Color(0xFF192133),
                    fontSize: 44,
                    fontFamily: 'Archivo',
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 30),

                // --- First Name ---
                TextFormField(
                  controller: _firstNameController,
                  decoration: _buildInputDecoration('First Name'),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your first name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // --- Last Name ---
                TextFormField(
                  controller: _lastNameController,
                  decoration: _buildInputDecoration('Last Name'),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your last name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // --- Phone Number ---
                TextFormField(
                  controller: _phoneController,
                  decoration: _buildInputDecoration('Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // --- Date of Birth ---
                TextFormField(
                  controller: _dobController,
                  decoration: _buildInputDecoration(
                    'Date of Birth',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your date of birth.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // --- Gender ---
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: _buildInputDecoration('Gender'),
                  hint: const Text(
                    'Select Gender',
                    style: TextStyle(
                      color: Color(0x80192133),
                      fontFamily: 'Archivo',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  items: _genderOptions.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your gender.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // --- Submit Button ---
                _RoleButton(
                  text: 'Sign Up', // Final step button text
                  onPressed: _trySubmitForm,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for consistent styling
  InputDecoration _buildInputDecoration(
    String labelText, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      fillColor: Colors.white,
      filled: true,
      enabledBorder: null,
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFF06638)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2.0),
      ),
      labelText: labelText,
      labelStyle: const TextStyle(
        color: Color(0x80192133),
        fontFamily: 'Archivo',
        fontWeight: FontWeight.w300,
      ),
      suffixIcon: suffixIcon,
    );
  }
}

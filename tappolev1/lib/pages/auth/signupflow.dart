import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tappolev1/components/styled_snackbar.dart';
import 'package:tappolev1/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tappolev1/theme/app_styles.dart';
import 'package:tappolev1/components/primary_button.dart';
import 'package:tappolev1/theme/app_colors.dart';

// 1. Add 'onboarding' to the steps enum
enum SignupSteps {
  onboarding,
  roleSelection,
  emailPasswordEntry,
  userDetailsEntry,
}

class Signupflow extends StatefulWidget {
  const Signupflow({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const Signupflow());
  }

  @override
  State<Signupflow> createState() => _SignupflowState();
}

class _SignupflowState extends State<Signupflow> {
  // 2. Initialize with onboarding
  SignupSteps _currentStep = SignupSteps.onboarding;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final supabase = Supabase.instance.client;

  String _role = '';
  String _email = '';
  String _password = '';

  void _nextStep(SignupSteps step) {
    setState(() {
      _currentStep = step;
    });
  }

  // --- Callbacks ---

  /// Called when user finishes Onboarding
  void _onOnboardingComplete() {
    setState(() {
      _currentStep = SignupSteps.roleSelection;
    });
  }

  void _onRoleSelected(String role) {
    setState(() {
      _role = role;
      _currentStep = SignupSteps.emailPasswordEntry;
    });
  }

  void _onEmailPasswordSubmitted(String email, String password) async {
    setState(() {
      _email = email;
      _password = password;
      _currentStep = SignupSteps.userDetailsEntry;
    });
  }

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

      await supabase.from('profiles').insert({
        'id': userId,
        'role': _role,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'dob': dob.toIso8601String(),
        'gender': gender,
      });

      await supabase.auth.signOut();

      if (!mounted) return;

      StyledSnackbar.show(
        context: context,
        message: 'Sign up successful! Please login with your new credentials.',
        type: SnackbarType.success,
      );

      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      StyledSnackbar.show(
        context: context,
        message: e.message,
        type: SnackbarType.error,
      );
    } catch (e) {
      if (!mounted) return;
      StyledSnackbar.show(
        context: context,
        message: 'An unexpected error occurred: $e',
        type: SnackbarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentWidget;

    switch (_currentStep) {
      case SignupSteps.onboarding:
        currentWidget = OnboardingStep(onComplete: _onOnboardingComplete);
        break;

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
          role: _role,
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

class OnboardingStep extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingStep({super.key, required this.onComplete});

  @override
  State<OnboardingStep> createState() => _OnboardingStepState();
}

class _OnboardingStepState extends State<OnboardingStep> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome\nto Tappole!',
      'description':
          'Welcome to Tappole, where you can seek for digital help or offer a kind hand!',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'If you are a\nsenior...',
      'description':
          'You can seek help with daily digital tasks, such as reading e-Vouchers or signing up for memberships!',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'If you are a\nvolunteer...',
      'description':
          'You can provide a valuable helping hand (tap!) for seniors who need a bit more guidance navigating the digital world.',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(page['image']!, fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset('assets/images/logo2.png', height: 100),
                        const SizedBox(height: 20),
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: lighth2TextStyle,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page['description']!,
                          textAlign: TextAlign.center,
                          style: lightpTextStyle,
                        ),
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white24,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentPage > 0
                          ? IconButton(
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            )
                          : const SizedBox(width: 48),

                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            widget.onComplete();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RoleSelectionStep extends StatefulWidget {
  final Function(String role) onRoleSelected;

  const RoleSelectionStep({super.key, required this.onRoleSelected});

  @override
  State<RoleSelectionStep> createState() => _RoleSelectionStepState();
}

class _RoleSelectionStepState extends State<RoleSelectionStep> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/loginbg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/images/logo2.png'),
              height: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Please select your role.',
              style: lighth2TextStyle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 60),

            _buildSelectableButton(label: 'I am a Senior!', value: 'senior'),

            const SizedBox(height: 25),

            _buildSelectableButton(
              label: 'I am a Volunteer!',
              value: 'volunteer',
            ),

            const SizedBox(height: 60),

            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _selectedRole != null ? 1.0 : 0.5,
              child: PrimaryButton(
                text: 'Confirm',
                onPressed: _selectedRole != null
                    ? () => widget.onRoleSelected(_selectedRole!)
                    : () {
                        StyledSnackbar.show(
                          context: context,
                          message: 'Please select a role to continue.',
                          type: SnackbarType.info,
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableButton({
    required String label,
    required String value,
  }) {
    final bool isSelected = _selectedRole == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : Colors.white,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryOrange.withAlpha(100),
                    blurRadius: 30,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(label, textAlign: TextAlign.center, style: lightpTextStyle),
      ),
    );
  }
}

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
    widget.onSubmitted(_emailController.text, _passwordController.text);
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
            image: AssetImage('assets/images/login2bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryOrange,
                      size: 28,
                    ),
                    onPressed: widget.onPrevious,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Image(
                  image: AssetImage('assets/images/logo3.png'),
                  height: 80.0,
                ),
                const SizedBox(height: 10),
                Text(
                  'Please enter your \nemail & password',
                  style: primaryh2TextStyle.copyWith(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  'Let\'s set up your account!',
                  style: primarypTextStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                TextFormField(
                  style: primaryInputLabelTextStyle,
                  controller: _emailController,
                  decoration: primaryInputDecoration.copyWith(
                    labelText: 'Email Address',
                  ),
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

                TextFormField(
                  style: primaryInputLabelTextStyle,
                  controller: _passwordController,
                  decoration: primaryInputDecoration.copyWith(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return 'Password must be at least 6 characters long.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                TextFormField(
                  style: primaryInputLabelTextStyle,
                  controller: _confirmPasswordController,
                  decoration: primaryInputDecoration.copyWith(
                    labelText: 'Confirm Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                PrimaryButton(text: 'Continue', onPressed: _trySubmitForm),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
  final String role;

  const UserDetailsStep({
    super.key,
    required this.onSubmitted,
    required this.onPrevious,
    required this.role,
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                SizedBox(height: MediaQuery.of(context).padding.top + 20),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: AppColors.primaryOrange,
                          size: 28,
                        ),
                        onPressed: widget.onPrevious,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Hey ${widget.role}, great to see you here!',
                  style: primaryh2TextStyle.copyWith(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  'We just have to know a little bit more about you. Please tell us your details!',
                  style: primarypTextStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),

                TextFormField(
                  style: primaryInputLabelTextStyle,
                  controller: _firstNameController,
                  decoration: primaryInputDecoration.copyWith(
                    labelText: 'First Name',
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your first name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                TextFormField(
                  style: primaryInputLabelTextStyle,
                  controller: _lastNameController,
                  decoration: primaryInputDecoration.copyWith(
                    labelText: 'Last Name',
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your last name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                TextFormField(
                  style: primaryInputLabelTextStyle,
                  controller: _phoneController,
                  decoration: primaryInputDecoration.copyWith(
                    labelText: 'Phone Number',
                    hintText: 'e.g., 0123456789',
                  ),
                  keyboardType: TextInputType.phone,

                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number.';
                    }

                    if (value.length < 8) {
                      return 'Phone number is too short.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                TextFormField(
                  style: primaryInputLabelTextStyle,
                  controller: _dobController,
                  decoration: primaryInputDecoration.copyWith(
                    labelText: 'Date of Birth',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        _selectedDate == null) {
                      return 'Please select your date of birth.';
                    }

                    if (widget.role == 'senior') {
                      final now = DateTime.now();
                      int age = now.year - _selectedDate!.year;
                      if (now.month < _selectedDate!.month ||
                          (now.month == _selectedDate!.month &&
                              now.day < _selectedDate!.day)) {
                        age--;
                      }

                      if (age < 55) {
                        return 'You must be at least 55 years old as a senior.';
                      }
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: primaryInputDecoration.copyWith(
                    labelText: 'Gender',
                  ),
                  hint: Text(
                    'Select Gender',
                    style: primarypTextStyle.copyWith(
                      color: AppColors.mediumAlphaDarkBlue,
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

                PrimaryButton(text: 'Sign Up', onPressed: _trySubmitForm),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

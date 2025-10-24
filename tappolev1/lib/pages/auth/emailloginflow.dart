import 'package:flutter/material.dart';
import '../../components/senior_navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- ENUM and Main Widget (Parent State Management) ---

enum EmailSteps { welcome, emailPasswordEntry }

class Emailloginflow extends StatefulWidget {
  const Emailloginflow({super.key});

  @override
  State<Emailloginflow> createState() => _EmailloginflowState();
}

class _EmailloginflowState extends State<Emailloginflow> {
  EmailSteps _currentStep = EmailSteps.welcome;

  // Data State managed by the parent widget
  String _email = '';
  String _password = '';

  // --- Navigation & State Update Methods ---

  void _nextStep(EmailSteps step) {
    setState(() {
      _currentStep = step;
    });
  }

  void _signInAndNavigate(String email, String password) async {
    // 1. Save the credentials (optional, mainly for debugging/logging)
    _email = email;
    _password = password;

    // 2. >>> SUPABASE INTEGRATION POINT 1: SIGN IN <<<
    final supabase = Supabase.instance.client;
    Future<AuthResponse> signInWithEmailPassword(
      String email,
      String password,
    ) async {
      return await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    }

    // --- Placeholder for fetching user role ---
    // In a real app, after a successful sign-in, you fetch the role
    // from your 'profiles' table using the current user's ID.

    // ** SIMULATE ROLE FETCHING: Replace with real logic **
    // For demonstration, let's assume a function that returns the role string.
    String userRole = await _fetchUserRolePlaceholder();

    // 3. Navigate based on the fetched role
    if (!mounted) return;

    if (userRole == 'senior') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SeniorNavBar()),
      );
    } else if (userRole == 'volunteer') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SeniorNavBar()),
      );
    } else {
      // Handle unassigned role or error case
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User role not found.')),
      );
      // Optionally navigate back to login
      _nextStep(EmailSteps.emailPasswordEntry);
    }
  }

  // Placeholder function to simulate fetching the user's role
  // (e.g., from the 'profiles' table after successful login)
  Future<String> _fetchUserRolePlaceholder() async {
    // Replace with your actual Supabase query!
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay

    // Simple logic based on email for testing:
    if (_email.contains('senior')) {
      return 'senior';
    } else if (_email.contains('volunteer')) {
      return 'volunteer';
    }
    return 'unassigned';
  }

  // --- Build Method (Conditional Rendering) ---

  @override
  Widget build(BuildContext context) {
    Widget currentWidget;

    switch (_currentStep) {
      case EmailSteps.welcome:
        currentWidget = WelcomeStep(
          onNext: () => _nextStep(EmailSteps.emailPasswordEntry),
        );
        break;
      case EmailSteps.emailPasswordEntry:
        currentWidget = EmailPasswordStep(
          onSubmitted: _signInAndNavigate, // Sends credentials for sign-in
          onPrevious: () => _nextStep(EmailSteps.welcome),
        );
        break;
    }

    return Scaffold(body: currentWidget);
  }
}

// ====================================================================
// --- WIDGET STEP DEFINITIONS ---
// ====================================================================

// Step 1: Welcome (Reused from OTP Flow, simplified for clarity)
class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  const WelcomeStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/loginbg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 250.0),
            Image.asset('assets/images/logo.png', height: 150.0),
            const SizedBox(height: 100.0),
            Container(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50.0,
                    vertical: 15.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  onNext();
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Archivo',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Don't have an account yet? ",
                  style: TextStyle(color: Colors.white, fontFamily: 'Archivo'),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to registration page
                  },
                  child: const Text(
                    'Register here.',
                    style: TextStyle(
                      color: Color(0xFFF06638),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Step 2: Email and Password Entry
class EmailPasswordStep extends StatefulWidget {
  // onSubmitted accepts both email and password
  final Function(String email, String password) onSubmitted;
  final VoidCallback onPrevious;

  const EmailPasswordStep({
    super.key,
    required this.onSubmitted,
    required this.onPrevious,
  });

  @override
  State<EmailPasswordStep> createState() => _EmailPasswordStepState();
}

class _EmailPasswordStepState extends State<EmailPasswordStep> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            image: AssetImage('assets/images/login2bg.png'),
            fit: BoxFit.cover,
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Login to \nyour \naccount',
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
              'Please enter your email and password.',
              style: TextStyle(
                fontSize: 15,
                height: 1.05,
                fontFamily: 'Archivo',
                fontWeight: FontWeight.w300,
                color: Color(0xFF192133),
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                enabledBorder: null,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFF06638)),
                ),
                labelText: 'Email Address',
                labelStyle: TextStyle(
                  color: Color(0x80192133),
                  fontFamily: 'Archivo',
                  fontWeight: FontWeight.w300,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                enabledBorder: null,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFF06638)),
                ),
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Color(0x80192133),
                  fontFamily: 'Archivo',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 80),

            Container(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  widget.onSubmitted(
                    _emailController.text.trim(),
                    _passwordController.text,
                  );
                },
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Archivo',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Or ", style: TextStyle(color: Color(0x80192133))),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'login with Email and Password',
                    style: TextStyle(
                      color: Color(0xFFF06638),
                      fontWeight: FontWeight.bold,
                      // decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

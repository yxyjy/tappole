import 'package:flutter/material.dart';
import 'package:tappolev1/components/primary_button.dart';
import 'package:tappolev1/pages/auth/otploginflow.dart';
import 'package:tappolev1/services/auth_service.dart';
import '../../components/senior_navbar.dart';
import '../../components/volunteer_navbar.dart';
import '../auth/signupflow.dart';
import '../../theme/app_styles.dart';

enum EmailSteps { welcome, emailPasswordEntry }

class Emailloginflow extends StatefulWidget {
  const Emailloginflow({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const Emailloginflow());
  }

  @override
  State<Emailloginflow> createState() => _EmailloginflowState();
}

class _EmailloginflowState extends State<Emailloginflow> {
  EmailSteps _currentStep = EmailSteps.welcome;
  bool _isLoading = false;

  //auth service
  final AuthService authService = AuthService();

  //method to navigate to next page
  void _nextStep(EmailSteps step) {
    setState(() {
      _currentStep = step;
    });
  }

  //method to attempt login
  void _signInAndNavigate(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await authService.signInWithEmailPassword(email, password);

      final String? userRole = await authService.getCurrentUserRole();

      if (!mounted) return;

      if (userRole == 'senior') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SeniorNavBar()),
        );
      } else if (userRole == 'volunteer') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VolunteerNavbar()),
        );
      } else {
        // Handle unassigned role or error case - head back to senior side
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User role not found.')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SeniorNavBar()),
        );
        // Optionally navigate back to login
        // _nextStep(EmailSteps.emailPasswordEntry);
      }
    } catch (e) {
      //handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Account not found!')));
    }
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
            const SizedBox(height: 80.0),
            Container(
              height: 50,
              width: 180,
              decoration: BoxDecoration(boxShadow: primaryButtonShadow),
              child: PrimaryButton(
                text: 'Login',
                onPressed: () {
                  onNext();
                },
              ),
            ),
            const SizedBox(height: 26.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Don't have an account yet? ", style: lightpTextStyle),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(Signupflow.route());
                  },
                  child: Text('Create an account', style: primaryLinkTextStyle),
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
              decoration: primaryInputDecoration.copyWith(
                labelText: 'Email Address',
              ),
              style: primaryInputLabelTextStyle,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: primaryInputDecoration.copyWith(
                labelText: 'Password',
              ),
              style: primaryInputLabelTextStyle,
              controller: _passwordController,
              obscureText: true,
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
              child: PrimaryButton(
                text: 'Login',
                onPressed: () {
                  widget.onSubmitted(
                    _emailController.text.trim(),
                    _passwordController.text,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Or ", style: TextStyle(color: Color(0x80192133))),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(Otploginflow.route());
                  },
                  child: const Text(
                    'login with Phone Number',
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

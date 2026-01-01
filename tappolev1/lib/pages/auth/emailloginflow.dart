import 'package:flutter/material.dart';
import 'package:tappolev1/components/primary_button.dart';
import 'package:tappolev1/pages/auth/otploginflow.dart';
import 'package:tappolev1/services/auth_service.dart';
import '../../components/senior_navbar.dart';
import '../../components/volunteer_navbar.dart';
import '../auth/signupflow.dart';
import '../../theme/app_styles.dart';
import '../../theme/app_colors.dart';
import '../../components/styled_snackbar.dart';

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
          MaterialPageRoute(builder: (_) => const VolunteerNavBar()),
        );
      } else {
        StyledSnackbar.show(
          context: context,
          message: 'Error: User role not found.',
          type: SnackbarType.error,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SeniorNavBar()),
        );
      }
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      final String errorString = e.toString().toLowerCase();

      if (errorString.contains('user-not-found') ||
          errorString.contains('invalid-email')) {
        errorMessage = 'No account found with this email.';
      } else if (errorString.contains('wrong-password') ||
          errorString.contains('invalid-credential')) {
        errorMessage = 'Incorrect password provided.';
      } else if (errorString.contains('too-many-requests')) {
        errorMessage = 'Too many attempts. Please try again later.';
      }

      if (mounted) {
        StyledSnackbar.show(
          context: context,
          message: errorMessage,
          type: SnackbarType.error,
        );
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
              width: 200,
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

class EmailPasswordStep extends StatefulWidget {
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login2bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 50.0),
                        Text(
                          'Login to \nyour \naccount',
                          style: primaryh2TextStyle,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Please enter your email and password.',
                          style: primarypTextStyle,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 40),

                        // Email Field
                        TextField(
                          controller: _emailController,
                          decoration: primaryInputDecoration.copyWith(
                            labelText: 'Email Address',
                          ),
                          style: primaryInputLabelTextStyle,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 10),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          decoration: primaryInputDecoration.copyWith(
                            labelText: 'Password',
                          ),
                          style: primaryInputLabelTextStyle,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                        ),

                        const SizedBox(height: 80),

                        // Login Button
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.lighterOrange.withAlpha(50),
                                spreadRadius: 10,
                                blurRadius: 50,
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

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Or ", style: primarypTextStyle),
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(
                                  context,
                                ).push(Otploginflow.route());
                              },
                              child: Text(
                                'login with Phone Number',
                                style: primarypTextStyle.copyWith(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tappolev1/pages/auth/signupflow.dart';
import '../../components/senior_navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

enum OtpSteps { welcome, phoneEntry, otpVerification }

// The main widget that hosts the PageView
class Otploginflow extends StatefulWidget {
  const Otploginflow({super.key});

  @override
  State<Otploginflow> createState() => _OtploginflowState();
}

class _OtploginflowState extends State<Otploginflow> {
  //final PageController _pageController = PageController();

  OtpSteps _currentStep = OtpSteps.phoneEntry;
  String _phoneNumber = '';

  void _nextStep(OtpSteps step) {
    setState(() {
      _currentStep = step;
    });
  }

  void _setPhoneAndAdvance(String phone) {
    // 1. Save the phone number
    _phoneNumber = phone;

    // 2. Call Supabase sign-inWithOtp function here (omitted for clean structure)
    // final supabase = Supabase.instance.client;
    // final response = await supabase.auth.signInWithOtp(phone: phone);

    // 3. Advance to the OTP verification step
    _nextStep(OtpSteps.otpVerification);
  }

  void _verifyOtpAndComplete(String otpCode) {
    // 1. Call Supabase verifyOtp function here (omitted for clean structure)
    // final response = await supabase.auth.verifyOTP(phone: _phoneNumber, token: otpCode);

    // 2. Navigate away on success
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const SeniorNavBar()));
  }

  void _goToPreviousStep() {
    setState(() {
      if (_currentStep == OtpSteps.otpVerification) {
        _currentStep = OtpSteps.phoneEntry;
      } else if (_currentStep == OtpSteps.phoneEntry) {
        _currentStep = OtpSteps.welcome;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentWidget;

    switch (_currentStep) {
      case OtpSteps.welcome:
        currentWidget = WelcomeStep(
          onNext: () => _nextStep(OtpSteps.phoneEntry),
        );
        break;
      case OtpSteps.phoneEntry:
        currentWidget = PhoneEntryWidget(
          onSubmitted:
              _setPhoneAndAdvance, // Passes phone number back and advances
          onPrevious: _goToPreviousStep,
        );
        break;
      case OtpSteps.otpVerification:
        currentWidget = OtpVerificationWidget(
          phoneNumber: _phoneNumber, // Passes the collected phone number down
          onComplete:
              _verifyOtpAndComplete, // Passes the final verification logic
          onPrevious: _goToPreviousStep,
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

class PhoneEntryWidget extends StatefulWidget {
  final ValueChanged<String> onSubmitted;
  final VoidCallback onPrevious;

  const PhoneEntryWidget({
    super.key,
    required this.onSubmitted,
    required this.onPrevious,
  });

  @override
  State<PhoneEntryWidget> createState() => _PhoneEntryWidgetState();
}

class _PhoneEntryWidgetState extends State<PhoneEntryWidget> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
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
              'Please enter your phone number. We will send you a text message with your OTP.',
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
              controller: _phoneController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                enabledBorder: null,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFF06638)),
                ),
                labelText: 'Phone Number',
                labelStyle: TextStyle(
                  color: Color(0x80192133),
                  fontFamily: 'Archivo',
                  fontWeight: FontWeight.w300,
                ),
                prefixText: '+60 ',
                prefixStyle: TextStyle(
                  color: Color(0x80192133),
                  fontFamily: 'Archivo',
                  fontWeight: FontWeight.w300,
                ),
              ),
              keyboardType: TextInputType.phone,
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
                  widget.onSubmitted(_phoneController.text.trim());
                },
                child: const Text(
                  'Confirm',
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
                  onTap: () {
                    // Navigate to registration page
                  },
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

// Step 3: Enter OTP (UPDATED)
class OtpVerificationWidget extends StatefulWidget {
  final String phoneNumber; // NEW: The number to verify
  final ValueChanged<String> onComplete; // onComplete now accepts the OTP code
  final VoidCallback onPrevious;

  const OtpVerificationWidget({
    super.key,
    required this.phoneNumber,
    required this.onComplete,
    required this.onPrevious,
  });

  @override
  State<OtpVerificationWidget> createState() => _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState extends State<OtpVerificationWidget> {
  // Store all 6 OTP digits in a single list
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getOtpCode() {
    return _otpControllers.map((c) => c.text).join();
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
            const SizedBox(height: 50),
            const Text(
              'Please enter your OTP.',
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  height: 50,
                  child: TextField(
                    autofocus: index == 0,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      counterText: "",
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF06638)),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                );
              }),
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
                    horizontal: 70.0,
                    vertical: 15.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  // Debug: confirm the button press reached here
                  widget.onComplete(_getOtpCode());
                },
                child: const Text(
                  'Confirm',
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
                  onTap: () {
                    Navigator.of(context).push(Signupflow.route());
                  },
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

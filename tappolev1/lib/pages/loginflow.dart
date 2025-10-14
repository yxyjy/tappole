import 'package:flutter/material.dart';
import 'main_shell.dart';

// The main widget that hosts the PageView
class LoginFlowPage extends StatefulWidget {
  const LoginFlowPage({super.key});

  @override
  State<LoginFlowPage> createState() => _LoginFlowPageState();
}

class _LoginFlowPageState extends State<LoginFlowPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _goToMainShell() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          WelcomeStep(onNext: _nextPage),
          PhoneStep(onNext: _nextPage, onPrevious: _previousPage),
          OtpStep(onComplete: _goToMainShell, onPrevious: _previousPage),
        ],
      ),
    );
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
            image: AssetImage('lib/assets/images/loginbg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 250.0),
            Image.asset('lib/assets/images/logo.png', height: 150.0),
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

// Step 2: Enter Phone Number (UPDATED)
class PhoneStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious; // NEW: Callback for the previous button
  const PhoneStep({super.key, required this.onNext, required this.onPrevious});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/login2bg.png'),
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
            const TextField(
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
                    horizontal: 100.0,
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
                  'Get OTP',
                  style: TextStyle(fontSize: 18, color: Colors.white),
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

            // NEW: Button layout
            // Row(
            //   children: [
            //     Expanded(
            //       child: OutlinedButton(
            //         onPressed: onPrevious,
            //         child: const Text('Previous'),
            //       ),
            //     ),
            //     const SizedBox(width: 16),
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: onNext,
            //         child: const Text('Send OTP'),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

// Step 3: Enter OTP (UPDATED)
class OtpStep extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback onPrevious; // NEW: Callback for the previous button
  const OtpStep({
    super.key,
    required this.onComplete,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/login2bg.png'),
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

            // Row(
            //   children: [
            //     const TextField(
            //       decoration: InputDecoration(
            //         fillColor: Colors.white,
            //         filled: true,
            //         enabledBorder: null,
            //         focusedBorder: OutlineInputBorder(
            //           borderSide: BorderSide(color: Color(0xFFF06638)),
            //         ),
            //         labelText: 'Phone Number',
            //         labelStyle: TextStyle(
            //           color: Color(0x80192133),
            //           fontFamily: 'Archivo',
            //           fontWeight: FontWeight.w300,
            //         ),
            //       ),
            //       keyboardType: TextInputType.phone,
            //     ),
            //     const TextField(
            //       decoration: InputDecoration(
            //         fillColor: Colors.white,
            //         filled: true,
            //         enabledBorder: null,
            //         focusedBorder: OutlineInputBorder(
            //           borderSide: BorderSide(color: Color(0xFFF06638)),
            //         ),
            //         labelText: 'Phone Number',
            //         labelStyle: TextStyle(
            //           color: Color(0x80192133),
            //           fontFamily: 'Archivo',
            //           fontWeight: FontWeight.w300,
            //         ),
            //       ),
            //       keyboardType: TextInputType.phone,
            //     ),
            //     const TextField(
            //       decoration: InputDecoration(
            //         fillColor: Colors.white,
            //         filled: true,
            //         enabledBorder: null,
            //         focusedBorder: OutlineInputBorder(
            //           borderSide: BorderSide(color: Color(0xFFF06638)),
            //         ),
            //         labelText: 'Phone Number',
            //         labelStyle: TextStyle(
            //           color: Color(0x80192133),
            //           fontFamily: 'Archivo',
            //           fontWeight: FontWeight.w300,
            //         ),
            //       ),
            //       keyboardType: TextInputType.phone,
            //     ),
            //     const TextField(
            //       decoration: InputDecoration(
            //         fillColor: Colors.white,
            //         filled: true,
            //         enabledBorder: null,
            //         focusedBorder: OutlineInputBorder(
            //           borderSide: BorderSide(color: Color(0xFFF06638)),
            //         ),
            //         labelText: 'Phone Number',
            //         labelStyle: TextStyle(
            //           color: Color(0x80192133),
            //           fontFamily: 'Archivo',
            //           fontWeight: FontWeight.w300,
            //         ),
            //       ),
            //       keyboardType: TextInputType.phone,
            //     ),
            //     const TextField(
            //       decoration: InputDecoration(
            //         fillColor: Colors.white,
            //         filled: true,
            //         enabledBorder: null,
            //         focusedBorder: OutlineInputBorder(
            //           borderSide: BorderSide(color: Color(0xFFF06638)),
            //         ),
            //         labelText: 'Phone Number',
            //         labelStyle: TextStyle(
            //           color: Color(0x80192133),
            //           fontFamily: 'Archivo',
            //           fontWeight: FontWeight.w300,
            //         ),
            //       ),
            //       keyboardType: TextInputType.phone,
            //     ),
            //     const TextField(
            //       decoration: InputDecoration(
            //         fillColor: Colors.white,
            //         filled: true,
            //         enabledBorder: null,
            //         focusedBorder: OutlineInputBorder(
            //           borderSide: BorderSide(color: Color(0xFFF06638)),
            //         ),
            //         labelText: 'Phone Number',
            //         labelStyle: TextStyle(
            //           color: Color(0x80192133),
            //           fontFamily: 'Archivo',
            //           fontWeight: FontWeight.w300,
            //         ),
            //       ),
            //       keyboardType: TextInputType.phone,
            //     ),
            //   ],
            // ),
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
                    horizontal: 100.0,
                    vertical: 15.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  onComplete();
                },
                child: const Text(
                  'Get OTP',
                  style: TextStyle(fontSize: 18, color: Colors.white),
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

            // NEW: Button layout
            // Row(
            //   children: [
            //     Expanded(
            //       child: OutlinedButton(
            //         onPressed: onPrevious,
            //         child: const Text('Previous'),
            //       ),
            //     ),
            //     const SizedBox(width: 16),
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: onNext,
            //         child: const Text('Send OTP'),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

// The destination after the login flow is the main app shell

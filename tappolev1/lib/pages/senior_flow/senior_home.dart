import 'package:flutter/material.dart';
import 'senior_request1.dart';

class SeniorHomePage extends StatefulWidget {
  const SeniorHomePage({super.key});
  @override
  _SeniorHomePageState createState() => _SeniorHomePageState();
}

class _SeniorHomePageState extends State<SeniorHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/seniorhomebg.png'),
            fit: BoxFit.cover,
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 54),
            const Text(
              'Struggling with downloading an app?',
              style: TextStyle(
                height: 1.0,
                color: Color(0xFF192133),
                fontSize: 36,
                fontFamily: 'Archivo',
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const Text(
              'In Tappole.  you can request for assistance from volunteers to help you out or guide you through digital tasks.',
              style: TextStyle(
                fontSize: 15,
                height: 1.05,
                fontFamily: 'Archivo',
                fontWeight: FontWeight.w300,
                color: Color(0xFF192133),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'That involves things like reading an e-voucher, sending an email or updating an app!',
              style: TextStyle(
                fontSize: 15,
                height: 1.05,
                fontFamily: 'Archivo',
                fontWeight: FontWeight.w300,
                color: Color(0xFF192133),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF06638).withAlpha(50),
                    spreadRadius: 10,
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF06638),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 30.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
                onPressed: () {
                  // Debug: confirm the button press reached here
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const SeniorRequest1Page(),
                    ),
                  );
                },
                child: Image.asset('assets/images/requestlogo.png'),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Tap to make a request!',
              style: TextStyle(
                fontSize: 15,
                height: 1.05,
                fontFamily: 'Archivo',
                fontWeight: FontWeight.w300,
                color: Color(0xFF192133),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

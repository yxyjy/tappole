import 'package:flutter/material.dart';
import 'senior_request1.dart';
import 'package:tappolev1/theme/app_styles.dart';
import 'package:tappolev1/theme/app_colors.dart';

class SeniorHomePage extends StatefulWidget {
  const SeniorHomePage({super.key});
  @override
  State<SeniorHomePage> createState() => _SeniorHomePageState();
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
            Text(
              'Struggling with downloading an app?',
              style: primaryh2TextStyle.copyWith(height: 1.1, fontSize: 36),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Text(
              'In Tappole.  you can request for assistance from volunteers to help you out or guide you through digital tasks.',
              style: primarypTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'That involves things like reading an e-voucher, sending an email or updating an app!',
              style: primarypTextStyle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            Container(
              // margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF06638).withAlpha(80),
                    spreadRadius: 10,
                    blurRadius: 50,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF06638),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 40.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
                onPressed: () {
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

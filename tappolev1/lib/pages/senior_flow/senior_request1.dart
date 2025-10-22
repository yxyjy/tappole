import 'package:flutter/material.dart';

class SeniorRequest1Page extends StatefulWidget {
  const SeniorRequest1Page({super.key});
  @override
  _SeniorRequest1PageState createState() => _SeniorRequest1PageState();
}

class _SeniorRequest1PageState extends State<SeniorRequest1Page> {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Hold the button and speak',
              style: TextStyle(
                height: 1.0,
                color: Color(0xFF192133),
                fontSize: 44,
                fontFamily: 'Archivo',
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            const Text(
              'Tell us - and the volunteers what you need!',
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
                  backgroundColor: const Color(0xFFF06638),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 70.0,
                    vertical: 70.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
                onPressed: () {
                  // Debug: confirm the button press reached here
                },
                child: Image.asset('assets/images/miclogo.png'),
              ),
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
                labelText: 'Your Message',
                labelStyle: TextStyle(
                  color: Color(0x80192133),
                  fontFamily: 'Archivo',
                  fontWeight: FontWeight.w300,
                ),
              ),
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 80),

            const Text(
              'Back',
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

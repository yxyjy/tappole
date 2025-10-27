import 'package:flutter/material.dart';

//INPUT FIELD STYLES
final primaryInputDecoration = InputDecoration(
  floatingLabelBehavior: FloatingLabelBehavior.always,
  labelStyle: TextStyle(
    color: Color(0xFFF06638),
    fontFamily: 'Archivo',
    fontWeight: FontWeight.w200,
  ),
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(
      color: Color.fromARGB(0, 25, 33, 51),
      width: 1.0,
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(color: Color(0x33192133), width: 1.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(color: Color(0xFFF06638), width: 2.0),
  ),
);

final primaryInputLabelTextStyle = TextStyle(
  color: Color.fromARGB(255, 25, 33, 51),
  fontFamily: 'Archivo',
  fontWeight: FontWeight.w200,
);

//LINK TEXT STYLES
final primaryLinkTextStyle = TextStyle(
  fontSize: 15.0,
  color: Color(0xFFF06638),
  fontWeight: FontWeight.bold,
  decoration: TextDecoration.underline,
  fontFamily: 'Archivo',
  decorationColor: const Color(0xFFF06638),
);

//TEXT STYLES
final primaryh2TextStyle = TextStyle(
  height: 1.0,
  color: Color(0xFF192133),
  fontSize: 44,
  fontFamily: 'Archivo',
  fontWeight: FontWeight.w900,
);

final lighth2TextStyle = TextStyle(
  fontSize: 44.0,
  color: Color.fromARGB(255, 255, 255, 255),
  fontWeight: FontWeight.w900,
  fontFamily: 'Archivo',
  height: 1.0,
);

final primarypTextStyle = TextStyle(
  height: 1.0,
  color: Color(0xFF192133),
  fontSize: 15,
  fontFamily: 'Archivo',
  fontWeight: FontWeight.w100,
);

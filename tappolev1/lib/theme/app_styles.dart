import 'package:flutter/material.dart';
import 'app_colors.dart';

//INPUT FIELD STYLES
final primaryInputDecoration = InputDecoration(
  floatingLabelBehavior: FloatingLabelBehavior.always,
  labelStyle: TextStyle(
    color: AppColors.primaryOrange,
    fontFamily: 'Archivo',
    fontWeight: FontWeight.w200,
  ),
  hintStyle: TextStyle(
    color: AppColors.lowerAlphaDarkBlue,
    fontFamily: 'Archivo',
    fontWeight: FontWeight.w200,
  ),
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20.0),
    borderSide: const BorderSide(
      color: AppColors.lowerAlphaDarkBlue,
      width: 1.0,
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20.0),
    borderSide: const BorderSide(
      color: Color.fromARGB(0, 25, 33, 51),
      width: 1.0,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20.0),
    borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2.0),
  ),
);

final primaryInputLabelTextStyle = TextStyle(
  color: AppColors.primaryDarkBlue,
  fontFamily: 'Archivo',
  fontWeight: FontWeight.w200,
);

final orangeLabelTextStyle = TextStyle(
  color: AppColors.primaryOrange,
  fontFamily: 'Archivo',
  fontSize: 12.0,
  fontWeight: FontWeight.w200,
);

final mediumAlphaInputTextStyle = TextStyle(
  color: AppColors.mediumAlphaDarkBlue,
  fontFamily: 'Archivo',
  fontWeight: FontWeight.w200,
  fontSize: 13.0,
);

//LINK TEXT STYLES
final primaryLinkTextStyle = TextStyle(
  fontSize: 15.0,
  color: AppColors.primaryOrange,
  fontWeight: FontWeight.bold,
  decoration: TextDecoration.underline,
  fontFamily: 'Archivo',
  decorationColor: AppColors.primaryOrange,
);

//TEXT STYLES
final primaryh2TextStyle = TextStyle(
  height: 1.0,
  color: AppColors.primaryDarkBlue,
  fontSize: 44,
  fontFamily: 'Archivo',
  fontWeight: FontWeight.w900,
);

final lighth2TextStyle = TextStyle(
  fontSize: 44.0,
  color: AppColors.white,
  fontWeight: FontWeight.w900,
  fontFamily: 'Archivo',
  height: 1.0,
);

final primarypTextStyle = TextStyle(
  height: 1.0,
  color: AppColors.primaryDarkBlue,
  fontSize: 15,
  fontFamily: 'Archivo',
  fontWeight: FontWeight.w100,
);

final lightpTextStyle = TextStyle(
  height: 1.0,
  color: AppColors.white,
  fontSize: 15,
  fontFamily: 'Archivo',
  fontWeight: FontWeight.w100,
);

final List<BoxShadow> primaryButtonShadow = [
  BoxShadow(
    color: AppColors.lowerAlphaDarkBlue,
    blurRadius: 20,
    spreadRadius: 0,
    offset: Offset(0, 0),
  ),
];

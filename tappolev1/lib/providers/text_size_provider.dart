import 'package:flutter/material.dart';

class TextSizeProvider extends ChangeNotifier {
  double _textScale = 1.0;

  double get textScale => _textScale;

  void setTextScale(double value) {
    _textScale = value.clamp(0.8, 1.5);
    notifyListeners();
  }
}

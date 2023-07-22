import 'dart:async';
import 'package:flutter/cupertino.dart';

class Placehold with ChangeNotifier {
  String _text = "New Task";
  String get text => _text;

  void updatePlaceholder(String newText, int duration) {
    _text = newText;
    Timer(Duration(milliseconds: duration), () {
      resetText();
    });
    notifyListeners();
  }

  void updatePlaceholderWithoutTimer(String newText) {
    _text = newText;

    notifyListeners();
  }

  void resetText() {
    _text = "New Task";
    notifyListeners();
  }
}

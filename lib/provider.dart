import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Placehold with ChangeNotifier {
  String _text = "New Task";
  String get text => _text;

  void updatePlaceholder(String newText, int duration) {
    _text = newText;
    Timer(Duration(milliseconds: duration), () {
      defaultText();
    });
    notifyListeners();
  }

  void updatePlaceholderWithoutTimer(String newText) {
    _text = newText;

    notifyListeners();
  }

  void defaultText() {
    DateTime date = DateTime.now();
    DateFormat formatter = DateFormat.MMMMEEEEd();
    _text = formatter.format(date);

    notifyListeners();
  }

  // void resetText() {
  //   _text = "New Task";
  //   notifyListeners();
  // }
}

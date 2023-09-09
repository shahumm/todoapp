import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Placehold with ChangeNotifier {
  // Text Field
  String _text = "New Task";
  String get text => _text;

  // Transition
  bool _showTransition = false;
  bool get showTransition => _showTransition;

  void updateShowTransition(bool status) {
    _showTransition = status;
    notifyListeners();
  }

  // Time Exceeded
  bool _timeExceeded = false;
  bool get timeExceeded => _timeExceeded;

  void isTimeExceeded(bool status) {
    _timeExceeded = status;
    notifyListeners();
  }

  // Time Found In Task
  bool _timeFound = false;
  bool get timeFound => _timeFound;

  void isTimeFound(bool status) {
    _timeFound = status;
    notifyListeners();
  }

  // New Task Highlight
  bool _highlightTask = false;
  bool get highlightTask => _highlightTask;

  void updateHighlightStatus(bool status) {
    _highlightTask = status;
    notifyListeners();
  }

  // Editing
  bool _isEditing = false;
  bool get isEditing => _isEditing;

  void updateEditStatus(bool status) {
    _isEditing = status;
    notifyListeners();
  }

  // Change Text With Timer
  void updatePlaceholder(String newText, int duration) {
    _text = newText;
    Timer(Duration(milliseconds: duration), () {
      defaultText();
    });
    notifyListeners();
  }

  // Change Text Without Timer
  void updatePlaceholderWithoutTimer(String newText) {
    _text = newText;

    notifyListeners();
  }

  // Reset Text
  void defaultText() {
    DateTime date = DateTime.now();
    DateFormat formatter = DateFormat.MMMMEEEEd();
    _text = formatter.format(date);

    notifyListeners();
  }
}

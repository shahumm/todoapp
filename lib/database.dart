import 'package:hive/hive.dart';

class Database {
  List todoList = [];
  String name = 'hi';

  // Referencing Box
  final _box = Hive.box('dataBox');

  // First Time Opening the App
  void welcomeData() {
    todoList = [
      ["Download Increment", true],
    ];
  }

  // Read Database
  void readDatabase() {
    todoList = _box.get("TodoList");
  }

  // Update Database
  void updateDatabase() {
    _box.put("TodoList", todoList);
  }

  // Read Database
  void readName() {
    name = _box.get("Name");
  }

  // Update User
  void updateName(String newName) {
    name = newName;
    _box.put("Name", name);
  }
}

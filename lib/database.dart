import 'package:hive/hive.dart';

class Database {
  List todoList = [];
  String name = 'hi';

  // Referencing Box
  final _box = Hive.box('dataBox');

  // First Time Opening the App
  void welcomeData() {
    todoList = [
      ["Download Todo App", true],
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

  // After Editing
  void updateTaskName(int index, String newName) {
    todoList[index][0] = newName;
    updateDatabase();
  }
}

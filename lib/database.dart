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

  void readName() {
    var nameFromBox = _box.get("Name");
    if (nameFromBox != null && nameFromBox is String) {
      name = nameFromBox;
    } else {
      // If the value in the box is null or not a String, you can provide a default value or handle the error accordingly.
      name = "Default Name";
    }
  }

  // Update User
  void updateName(String newName) {
    name = newName;
    _box.put("Name", name);
  }

  // After Editing
  void updateTaskName(int index, String newName) {
    todoList[index][0] = newName;
    updateDatabase();
  }
}

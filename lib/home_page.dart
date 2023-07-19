import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:todoapp/tasks.dart';
import 'package:todoapp/todo_tile.dart';

class HomePage extends StatefulWidget {
  final Isar isar;
  const HomePage({Key? key, required this.isar});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _newTask = TextEditingController();
  List<List<dynamic>> todoList = []; // Update the type of todoList

  @override
  void initState() {
    super.initState();
    fetchTasks(); // Fetch tasks when the widget is initialized
  }

  Future<void> fetchTasks() async {
    final tasks =
        await widget.isar.tasks.where().findAll(); // Fetch all tasks from Isar
    setState(() {
      todoList = tasks
          .map((task) => [task.title, task.isCompleted])
          .toList(); // Update todoList with tasks
    });
  }

  // Checkbox Tapped
  void updateCheckbox(bool? value, int index) {
    setState(() {
      todoList[index][1] = !todoList[index][1];
    });
  }

  // Saving New Task to Database
  void saveNewTask() async {
    setState(() async {
      final task = widget.isar.tasks;
      final newTask = Tasks()
        ..title = _newTask.text
        ..isCompleted = false
        ..createdAt = DateTime.now();
      await widget.isar.writeTxn(() async {
        await task.put(newTask);
      });

      // Clears Text Field After New Task
      _newTask.clear();
      fetchTasks(); // Fetch tasks again to update the todoList
    });
    Navigator.of(context).pop();
  }

  // Creating New Task
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: 120,
            child: Column(
              children: [
                TextField(
                  controller: _newTask,
                ),
                Row(
                  children: [
                    // Save Task
                    MaterialButton(
                      onPressed: saveNewTask,
                      child: const Text("Create"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Removing Task
  void removeTask(int index) {
    setState(() {
      todoList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 221, 221, 221),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),

      // Add New Task
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.grey,
        onPressed: createNewTask,
      ),

      // Tasks Being Built
      body: ListView.builder(
        itemCount: todoList.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              setState(() {
                removeTask(index);
              });
            },
            background: Container(
              color: Colors.red,
            ),
            child: TodoTile(
              index: index,
              isar: widget.isar,
              onChanged: (value) {
                updateCheckbox(value, index);
              },
            ),
          );
        },
      ),
    );
  }
}

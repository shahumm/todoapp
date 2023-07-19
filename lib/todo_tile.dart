import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:todoapp/tasks.dart';

class TodoTile extends StatelessWidget {
  // Variables
  final int index;
  final Isar isar;
  final Function(bool?)? onChanged;

  // Constructor
  const TodoTile(
      {super.key,
      required this.index,
      required this.isar,
      required this.onChanged});

  Future<Map<String, dynamic>> readTask() async {
    final tasks = isar.tasks;
    final task = await tasks.get(index + 1);

    final taskTitle = task?.title ?? 'Task not found';
    final taskCompleted = task?.isCompleted;

    return {'title': taskTitle, 'completed': taskCompleted};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: readTask(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final taskData = snapshot.data ?? {};
        final taskTitle = taskData['title'] as String;
        final taskCompleted = taskData['completed'] as bool;
        return ListTile(
          title: Text(
            taskTitle,
            style: TextStyle(
              decoration: taskCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          trailing: Checkbox(value: taskCompleted, onChanged: onChanged),
        );
      },
    );
  }
}

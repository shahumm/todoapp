import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:todoapp/database.dart';
import 'package:todoapp/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.userName});

  final String userName;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _newTask = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isTextFieldFocused = false;

  // Referencing the Database
  final _box = Hive.box('dataBox');

  // Instantiation of Database
  Database db = Database();

  // App First Runs
  @override
  void initState() {
    if (_box.get("TodoList") == null) {
      // Database doesn't exist
      db.welcomeData();
      db.updateName(widget.userName);
    } else {
      // Database already exists
      db.readDatabase();
      db.updateName(widget.userName);
    }

    db.readName();

    // print('Widget UserName: ${widget.userName}');
    // print('Saved Name in Hive: ${_box.get("Name")}');
    super.initState();

    _focusNode.addListener(() {
      setState(() {
        isTextFieldFocused = _focusNode.hasFocus;
      });
    });
  }

  // Checkbox Tapped
  void updateCheckbox(bool? value, int index) {
    setState(() {
      db.todoList[index][1] = !db.todoList[index][1];
    });
    db.updateDatabase();
  }

  // Save Task
  void saveNewTask() {
    setState(() {
      db.todoList.add([_newTask.text, false]);
    });

    _newTask.clear();
    db.updateDatabase();
  }

  // // Creating New Task
  // void createNewTask() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         content: SizedBox(
  //           height: 120,
  //           child: Column(
  //             children: [
  //               TextField(
  //                 controller: _newTask,
  //               ),
  //               Row(
  //                 children: [
  //                   // Save Task
  //                   MaterialButton(
  //                     onPressed: () {
  //                       saveNewTask();
  //                     },
  //                     child: const Text("Create"),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // Removing Task
  void removeTask(int index) {
    setState(() {
      db.todoList.removeAt(index);
    });

    db.updateDatabase();
  }

  @override
  void dispose() {
    // Clean up the FocusNode when it's no longer needed
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 24, 24, 24),
        extendBodyBehindAppBar: true,

        // Add New Task
        // floatingActionButton: FloatingActionButton(
        //   elevation: 0,
        //   backgroundColor: const Color.fromARGB(255, 158, 158, 158),
        //   onPressed: createNewTask,
        // ),

        // Tasks Being Built
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Image(
                      image: AssetImage("assets/giphy copy.gif"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: ListView.builder(
                    itemCount: db.todoList.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = db.todoList.length - index - 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 13.0),
                        child: Dismissible(
                          key: UniqueKey(),
                          onDismissed: (direction) {
                            setState(() {
                              removeTask(reversedIndex);
                            });
                          },
                          background: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            color: const Color.fromARGB(255, 161, 52, 33),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 20),
                                      child: Icon(
                                        Icons.delete,
                                        color:
                                            Color.fromARGB(201, 255, 255, 255),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          child: TodoTile(
                            taskName: db.todoList[reversedIndex][0],
                            taskCompleted: db.todoList[reversedIndex][1],
                            onChanged: (value) {
                              updateCheckbox(value, reversedIndex);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 25,
                  right: 25,
                  bottom: 25,
                  top: 25,
                ),
                child: Expanded(
                  child: CupertinoTextField(
                    maxLines: null,
                    minLines: 1,
                    controller: _newTask,
                    focusNode: _focusNode,
                    padding: const EdgeInsets.all(16),
                    style: GoogleFonts.quicksand(
                      color: const Color.fromARGB(255, 239, 239, 239),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    placeholder: "Wassup?",
                    placeholderStyle: const TextStyle(color: Colors.grey),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                          color: _focusNode.hasFocus
                              ? const Color(0xFFD5B858)
                              : Colors.grey,
                          width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    cursorColor: const Color(0xFFD5B858),
                    suffix: _focusNode.hasFocus
                        ? CupertinoButton(
                            onPressed: () {
                              saveNewTask();
                              _focusNode.unfocus();
                            },
                            child: const Icon(
                              CupertinoIcons.add,
                              size: 23,
                              color: Color(0xFFD5B858),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

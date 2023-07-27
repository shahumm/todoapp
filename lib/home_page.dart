import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/database.dart';
import 'package:todoapp/provider.dart';
import 'package:todoapp/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Others
  final _newTask = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isTextFieldFocused = false;

  int textFieldMaxLines = 1;

  // Placeholder
  String celebrativeText = "New Task";

  // Referencing the Database
  final _box = Hive.box('dataBox');

  // Instantiation of Database
  Database db = Database();

  Widget interactIcon = const Icon(
    CupertinoIcons.bubble_left,
    size: 23,
    color: Colors.grey,
  );

  Widget theSnail = const Text(
    '🐌',
    style: TextStyle(fontSize: 18),
  );

  // App First Runs
  @override
  void initState() {
    if (_box.get("TodoList") == null) {
      // Database doesn't exist
      db.welcomeData();
      // db.updateName(widget.userName);
    } else {
      // Database already exists
      db.readDatabase();
      // db.updateName(widget.userName);
    }
    db.readName();

    super.initState();

    context.read<Placehold>().updatePlaceholderWithoutTimer(
          "Eeey Wassup, Shahum? 👀",
        );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        context.read<Placehold>().updatePlaceholderWithoutTimer(
              "About time! Lesss gooo!",
            );
      } else {
        context.read<Placehold>().resetText();
      }
    });
  }

  // That Tickled
  void thatTickled() {
    int time = 5000;
    context.read<Placehold>().updatePlaceholder(
          "You thought it was a button but it was me, a Snail, all along! That kinda tickled btw.",
          time,
        );

    setState(() {
      textFieldMaxLines = 3;
      interactIcon = theSnail;

      Timer(Duration(milliseconds: time), () {
        setState(() {
          interactIcon = const Icon(
            CupertinoIcons.bubble_left,
            size: 23,
            color: Colors.grey,
          );
        });
      });
    });
  }

// Save Task
  void saveNewTask() {
    setState(() {
      db.todoList.add([_newTask.text, false]);
    });
    _newTask.clear();
    db.updateDatabase();
  }

  // Removing Task
  void removeTask(int index) {
    setState(() {
      db.todoList.removeAt(index);
    });

    db.updateDatabase();
  }

  @override
  void dispose() {
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
        backgroundColor: const Color.fromARGB(255, 21, 21, 21),
        extendBodyBehindAppBar: true,
        // Tasks Being Built
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                flex: 2,
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
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: ListView.builder(
                    itemCount: db.todoList.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = db.todoList.length - index - 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
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
                            deleteFunction: (p0) => removeTask,
                            index: reversedIndex,
                            database: db,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: AnimatedSize(
                  duration: const Duration(
                    milliseconds: 100,
                  ),
                  curve: Curves.easeIn,
                  child: CupertinoTextField(
                    key: const ValueKey('veryUnique'),
                    maxLines: textFieldMaxLines,
                    minLines: 1,
                    controller: _newTask,
                    focusNode: _focusNode,
                    padding: const EdgeInsets.all(16),
                    style: GoogleFonts.quicksand(
                      color: const Color.fromARGB(255, 239, 239, 239),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    placeholder: context.watch<Placehold>().text,
                    placeholderStyle: const TextStyle(
                      color: Colors.grey,
                    ),
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
                              if (_newTask.text.trim().isEmpty) {
                                context.read<Placehold>().updatePlaceholder(
                                      "Umm, this is not how it works...",
                                      5000,
                                    );
                              } else {
                                saveNewTask();
                                _focusNode.unfocus();
                              }
                            },
                            child: const Icon(
                              CupertinoIcons.add,
                              size: 23,
                              color: Color(0xFFD5B858),
                            ),
                          )
                        : CupertinoButton(
                            onPressed: () {
                              thatTickled();
                            },
                            child: interactIcon,
                          ),
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

class Holder extends StatelessWidget {
  const Holder({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(context.watch<Placehold>().text, key: const Key('veryUnique'));
  }
}

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/database.dart';
import 'package:todoapp/provider.dart';
import 'package:todoapp/todo_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _newTask = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isTextFieldFocused = false;
  int textFieldMaxLines = 1;
  bool isLongPress = false;

  // Shared Preferences for Light / Dark Mode
  bool isLightMode = false;
  late SharedPreferences _prefs;

  // Referencing the Database
  final _box = Hive.box('dataBox');
  Database db = Database();

  // Circle Icon
  Widget interactIcon = Icon(
    CupertinoIcons.circle,
    size: 23,
    color: Colors.grey.shade600,
  );

  // Snail Icon
  Widget theSnail = const Text(
    '🐌',
    style: TextStyle(fontSize: 18),
  );

  // Current Date
  DateTime currentDate() {
    return DateTime.now();
  }

  @override
  void initState() {
    super.initState();

    _initPreferences();

    if (_box.get("TodoList") == null) {
      // Database doesn't exist
      db.welcomeData();
    } else {
      // Database already exists
      db.readDatabase();
    }
    // db.readName();

    super.initState();

    Future.delayed(Duration.zero, () {
      context.read<Placehold>().defaultText();
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        context.read<Placehold>().updatePlaceholderWithoutTimer(
              "About time! Lesss gooo!",
            );
      } else {
        context.read<Placehold>().defaultText();
      }
    });
  }

  // Initializing Shared Preferences
  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      isLightMode = _prefs.getBool('isLightMode') ?? false;
    });
  }

  Future<void> _saveModePreference(bool value) async {
    setState(() {
      isLightMode = value;
    });
    await _prefs.setBool('isLightMode', value);
  }

  // Change Theme
  void changeMode() {
    bool newMode = !isLightMode;
    _saveModePreference(newMode);

    if (newMode) {
      context.read<Placehold>().updatePlaceholder("Light Mode", 1000);
    } else {
      context.read<Placehold>().updatePlaceholder("Dark Mode", 1000);
    }
  }

  // Snail Appears
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
          interactIcon = Icon(
            CupertinoIcons.circle,
            size: 23,
            color: isLightMode ? Colors.grey.shade700 : Colors.grey,
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

  // Remove All Tasks
  void removeAllTasks() {
    setState(() {
      db.todoList.clear();
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
        backgroundColor: isLightMode
            ? Colors.grey.shade400
            : const Color.fromARGB(255, 26, 26, 26),
        extendBodyBehindAppBar: true,
        // Tasks Being Built
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50)),
                child: SizedBox(
                  width: double.infinity,
                  child: isLightMode
                      ? const Image(
                          image: AssetImage("assets/light.PNG"),
                          fit: BoxFit.cover,
                        )
                      : const Image(
                          image: AssetImage("assets/dark.PNG"),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Expanded(
                flex: 4,
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
                                      color: Color.fromARGB(201, 255, 255, 255),
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
                          isLightMode: isLightMode,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Consumer<Placehold>(
                builder: (context, placehold, _) {
                  return Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: isLightMode
                            ? Colors.grey.shade400
                            : const Color.fromARGB(255, 26, 26, 26),
                        offset: const Offset(0, -32),
                        blurRadius: 32,
                        spreadRadius: -2,
                      ),
                    ]),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeIn,
                      child: placehold.isEditing
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: _focusNode.hasFocus
                                  ? const EdgeInsets.only(
                                      top: 20,
                                      bottom: 25,
                                      left: 25,
                                      right: 25,
                                    )
                                  : const EdgeInsets.only(
                                      top: 20,
                                      bottom: 25,
                                      left: 38,
                                      right: 38,
                                    ),
                              child: CupertinoTextField(
                                key: const ValueKey('veryUnique'),
                                maxLines: textFieldMaxLines,
                                minLines: 1,
                                controller: _newTask,
                                focusNode: _focusNode,
                                padding: const EdgeInsets.all(16),
                                style: GoogleFonts.quicksand(
                                  color: isLightMode
                                      ? Colors.grey.shade800
                                      : const Color.fromARGB(
                                          255, 239, 239, 239),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                placeholder: context.watch<Placehold>().text,
                                placeholderStyle: TextStyle(
                                  color: isLightMode
                                      ? const Color.fromARGB(255, 90, 90, 90)
                                      : Colors.grey,
                                ),
                                decoration: BoxDecoration(
                                  color: isLightMode
                                      ? Colors.grey.shade400
                                      : const Color.fromARGB(255, 26, 26, 26),
                                  border: Border.all(
                                    color: _focusNode.hasFocus
                                        ? isLightMode
                                            ? const Color(0xFFAB7D00)
                                            : const Color(0xFFD5B858)
                                        : isLongPress
                                            ? const Color.fromARGB(
                                                255, 161, 52, 33)
                                            : Colors.grey.shade600,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(15),

                                  // Experimenting with Neumorphism
                                  boxShadow: [
                                    BoxShadow(
                                      color: isLightMode
                                          ? Colors.grey.shade600
                                          : Colors.black,
                                      offset: const Offset(4, 4),
                                      blurRadius: 20,
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: isLightMode
                                          ? Colors.grey.shade300
                                          : const Color.fromARGB(
                                              255, 36, 36, 36),
                                      offset: const Offset(-5, -5),
                                      blurRadius: 20,
                                      spreadRadius: 0,
                                    )
                                  ],
                                ),
                                cursorColor: isLightMode
                                    ? const Color(0xFFAB7D00)
                                    : const Color(0xFFD5B858),
                                suffix: _focusNode.hasFocus
                                    ? CupertinoButton(
                                        onPressed: () {
                                          if (_newTask.text.trim().isEmpty) {
                                            context
                                                .read<Placehold>()
                                                .updatePlaceholder(
                                                  "Umm, this is not how it works...",
                                                  5000,
                                                );
                                          } else {
                                            saveNewTask();
                                            _focusNode.unfocus();
                                          }
                                        },
                                        child: Icon(
                                          CupertinoIcons.add,
                                          size: 23,
                                          color: isLightMode
                                              ? const Color(0xFFAB7D00)
                                              : const Color(0xFFD5B858),
                                        ),
                                      )
                                    : GestureDetector(
                                        onLongPress: () {
                                          if (db.todoList.isNotEmpty) {
                                            setState(() {
                                              isLongPress = true;
                                              context
                                                  .read<Placehold>()
                                                  .updatePlaceholderWithoutTimer(
                                                    "All tasks deleted!",
                                                  );
                                            });
                                            removeAllTasks();
                                          } else {
                                            setState(() {
                                              isLongPress = true;
                                              context
                                                  .read<Placehold>()
                                                  .updatePlaceholderWithoutTimer(
                                                    "Locating nearby eye specialists...",
                                                  );
                                            });
                                          }
                                        },
                                        onLongPressEnd: (details) {
                                          setState(() {
                                            isLongPress = false;
                                            context
                                                .read<Placehold>()
                                                .defaultText();
                                          });
                                        },
                                        child: CupertinoButton(
                                          onPressed: () {
                                            if (isLongPress) {
                                            } else {
                                              thatTickled();
                                            }
                                          },
                                          child: isLongPress
                                              ? Icon(CupertinoIcons.delete,
                                                  size: 23,
                                                  color: isLightMode
                                                      ? Colors.grey.shade600
                                                      : Colors.grey)
                                              : interactIcon,
                                        ),
                                        onDoubleTap: () {
                                          changeMode();
                                        },
                                      ),
                              ),
                            ),
                    ),
                  );
                },
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

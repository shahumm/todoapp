import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
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
  int colorIndex = 0;

  final _newTask = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isTextFieldFocused = false;
  int textFieldMaxLines = 1;
  bool isLongPress = false;

  // Mute Switch
  bool isMute = false;

  // Calback Mute
  void _updateMutePreference(bool value) {
    setState(() {
      isMute = value;
    });
    _saveMutePreference(value);
  }

  // List Scrolls to Bottom When New Task Added
  final ScrollController _scrollController = ScrollController();

  // Audio
  final player = AudioPlayer();

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

    // Refresh App (For Time Left Update)
    Timer.periodic(const Duration(minutes: 5), (timer) {
      setState(() {});
    });

    // Change Text Colour If Time Detected
    _newTask.addListener(() {
      RegExp timePattern = RegExp(r'\b(?:\d{1,2}:)?\d{1,2}:\d{2}\b');
      bool containsTimePattern = timePattern.hasMatch(_newTask.text);

      context.read<Placehold>().isTimeFound(containsTimePattern);
    });
  }

  // Initializing Shared Preferences
  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      isLightMode = _prefs.getBool('isLightMode') ?? false;
      isMute = _prefs.getBool('isMute') ?? false;
    });
  }

  Future<void> _saveModePreference(bool value) async {
    setState(() {
      isLightMode = value;
    });
    await _prefs.setBool('isLightMode', value);
  }

  Future<void> _saveMutePreference(bool value) async {
    setState(() {
      isMute = value;
    });
    await _prefs.setBool('isMute', value);
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
      // New Task Sound
      if (!isMute) {
        player.play(AssetSource('newtask.mp3'));
      }
      db.todoList.add([_newTask.text, false]);
    });
    _newTask.clear();
    db.updateDatabase();

    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );

    // Highlight Text
    context.read<Placehold>().updateHighlightStatus(true);

    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        context.read<Placehold>().updateHighlightStatus(false);
      });
    });
  }

  // Removing Task
  void removeTask(int index) {
    setState(() {
      // Remove One Task Sound
      if (!isMute) {
        player.play(AssetSource('delete-task.mp3'));
      }

      db.todoList.removeAt(index);
    });

    db.updateDatabase();
  }

  // Remove All Tasks
  void removeAllTasks() {
    setState(() {
      // Delete All Tasks Sound
      if (!isMute) {
        player.play(AssetSource('delete.mp3'));
      }
      db.todoList.clear();
    });
    db.updateDatabase();
  }

  // Invalid Selection
  void invalidSelection() {
    setState(() {
      // Error Sound
      if (!isMute) {
        player.play(AssetSource('error.mp3'));
      }
    });
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

          // Tasks Being Built
          body: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        expandedHeight: 200,
                        flexibleSpace: FlexibleSpaceBar(
                          background: isLightMode
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
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          if (index >= 0 && index < db.todoList.length) {
                            final reversedIndex =
                                db.todoList.length - index - 1;

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
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
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
                                              color: Color.fromARGB(
                                                  201, 255, 255, 255),
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
                                  isMute: isMute,
                                ),
                              ),
                            );
                          }
                          if (index == db.todoList.length) {
                            if (db.todoList.isEmpty) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: const Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 30, right: 30),
                                    child: Text(
                                      "Your to-do list is as empty as a library at midnight.",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            Color.fromARGB(255, 125, 125, 125),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox(
                                height: 50.0,
                              );
                            }
                          }

                          return null;
                        }),
                      ),
                    ],
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
                                        top: 5,
                                        bottom: 25,
                                        left: 25,
                                        right: 25,
                                      )
                                    : const EdgeInsets.only(
                                        top: 5,
                                        bottom: 25,
                                        left: 38,
                                        right: 38,
                                      ),
                                child: GestureDetector(
                                  onVerticalDragUpdate: (details) {
                                    int sensitivity = 8;
                                    if (details.delta.dy < -sensitivity) {
                                      showModalBottomSheet(
                                        backgroundColor: null,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ModalElements(
                                            isMute: isMute,
                                            updateMutePreference:
                                                _updateMutePreference,
                                            isLightMode: isLightMode,
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: CupertinoTextField(
                                    key: const ValueKey('veryUnique'),
                                    maxLines: textFieldMaxLines,
                                    minLines: 1,
                                    controller: _newTask,
                                    focusNode: _focusNode,
                                    padding: const EdgeInsets.all(16),
                                    style: GoogleFonts.quicksand(
                                      color: placehold.timeFound
                                          ? isLightMode
                                              ? const Color.fromARGB(
                                                  255, 132, 113, 37)
                                              : const Color.fromARGB(
                                                  255, 205, 182, 105)
                                          : isLightMode
                                              ? Colors.grey.shade800
                                              : const Color.fromARGB(
                                                  255, 239, 239, 239),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    placeholder: placehold.text,
                                    placeholderStyle: TextStyle(
                                      color: isLightMode
                                          ? const Color.fromARGB(
                                              255, 90, 90, 90)
                                          : Colors.grey,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLightMode
                                          ? Colors.grey.shade400
                                          : const Color.fromARGB(
                                              255, 26, 26, 26),
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
                                        ),
                                      ],
                                    ),
                                    cursorColor: isLightMode
                                        ? const Color(0xFFAB7D00)
                                        : const Color(0xFFD5B858),
                                    suffix: _focusNode.hasFocus
                                        ? CupertinoButton(
                                            onPressed: () {
                                              if (_newTask.text
                                                  .trim()
                                                  .isEmpty) {
                                                placehold.updatePlaceholder(
                                                  "Umm, this is not how it works...",
                                                  5000,
                                                );

                                                invalidSelection();
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
                                                  placehold
                                                      .updatePlaceholderWithoutTimer(
                                                    "All tasks deleted!",
                                                  );
                                                });
                                                removeAllTasks();
                                              } else {
                                                setState(() {
                                                  invalidSelection();
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
                                                placehold.defaultText();
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
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

class ModalElements extends StatefulWidget {
  final bool isMute;
  final Function(bool) updateMutePreference;
  final bool isLightMode;

  const ModalElements(
      {super.key,
      required this.isMute,
      required this.updateMutePreference,
      required this.isLightMode});

  @override
  State<ModalElements> createState() => _ModalElementsState();
}

class _ModalElementsState extends State<ModalElements> {
  late bool isMute;

  @override
  void initState() {
    super.initState();
    isMute = widget.isMute;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isLightMode
            ? Colors.grey.shade400
            : const Color.fromARGB(255, 26, 26, 26),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(27.0),
          topRight: Radius.circular(27.0),
        ),
      ),
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Mute Toggle
            Padding(
              padding: const EdgeInsets.only(
                  left: 27.0, right: 27, top: 27, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mute Sounds',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: widget.isLightMode
                            ? const Color.fromARGB(255, 26, 26, 26)
                            : Colors.grey.shade400),
                  ),
                  Switch(
                    value: isMute,
                    onChanged: (value) {
                      setState(() {
                        isMute = value;
                      });
                      widget.updateMutePreference(isMute);
                    },
                    activeColor: Colors.green,
                    inactiveTrackColor: widget.isLightMode
                        ? Colors.grey.shade400
                        : const Color.fromARGB(255, 26, 26, 26),
                    inactiveThumbColor: widget.isLightMode
                        ? const Color.fromARGB(255, 137, 137, 137)
                        : Colors.grey,
                  ),
                ],
              ),
            ),

            // Divider
            Divider(
              color: widget.isLightMode
                  ? Colors.grey
                  : const Color.fromARGB(255, 57, 57, 57),
              thickness: 2,
              indent: 27,
              endIndent: 27,
            ),
          ],
        ),
      ),
    );
  }
}

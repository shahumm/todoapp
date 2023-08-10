import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/database.dart';
import 'package:todoapp/provider.dart';

class TodoTile extends StatefulWidget {
  // Variables
  final String taskName;
  final bool taskCompleted;
  final Function(BuildContext)? deleteFunction;
  final int index;
  final Database database;
  final bool isLightMode;

  // Constructor
  const TodoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.deleteFunction,
    required this.index,
    required this.database,
    required this.isLightMode,
  });

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  // Confetti
  final controller = ConfettiController();
  bool isPlaying = false;
  bool isChecked = false;
  bool isText = false;
  Timer? confettiTimer;
  String modifiedTask = '';
  String newTask = '';
  String keyword = "";

  // Time
  String taskTime = "";
  bool timeExceeded = false;

  // Edit Task
  bool isEditing = false;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isChecked = widget.taskCompleted;

    modifiedTask = widget.taskName;
    newTask = modifiedTask;

    // Confetti
    controller.addListener(() {
      isPlaying = controller.state == ConfettiControllerState.playing;
    });

    keyword = hasKeyword();

    _textEditingController.text = modifiedTask;
  }

  // Check If Date is Present
  bool hasDate(String text) {
    final RegExp datePattern = RegExp(r'([a-zA-Z]+) (\d+)');
    return datePattern.hasMatch(text);
  }

  // Detect Keyword
  String hasKeyword() {
    bool at = modifiedTask.toLowerCase().contains("at");
    bool on = modifiedTask.toLowerCase().contains("on");
    bool by = modifiedTask.toLowerCase().contains("by");

    if (at) {
      return "at";
    } else if (on) {
      return "on";
    } else if (by) {
      return "by";
    } else {
      return "0";
    }
  }

  // Modifying Task Name According to Date's Presence
  String conditionalTaskName(bool hasDate, String keyword) {
    int keywordIndex = modifiedTask.indexOf(keyword);
    if (hasDate) {
      return modifiedTask.substring(0, keywordIndex).trim();
    } else {
      return modifiedTask;
    }
  }

  String getTaskTime() {
    int keywordIndex = modifiedTask.indexOf(keyword);
    if (keywordIndex != -1 && keywordIndex + 8 <= modifiedTask.length) {
      String taskTimeSubstring =
          modifiedTask.substring(keywordIndex + 3, keywordIndex + 8).trim();

      taskTimeSubstring =
          taskTimeSubstring.replaceAll(RegExp(r'\b(at|on)\b'), '').trim();

      if (taskTimeSubstring.length == 5) {
        return taskTimeSubstring;
      }
    }
    return "bleh";
  }

  String formatRemainingTime(int hours, int minutes) {
    if (hours == 0 && minutes == 0) {
      timeExceeded = true;
      return "Time Exceeded";
    } else if (hours == 1 && minutes == 1) {
      timeExceeded = false;
      return "in $hours hour and $minutes minute";
    } else if (hours == 1) {
      timeExceeded = false;
      return "in $hours hour and $minutes minutes";
    } else if (minutes == 1) {
      timeExceeded = false;
      return "in $hours hours and $minutes minute";
    } else if (hours == 0) {
      timeExceeded = false;
      return "in $minutes minutes";
    } else if (minutes == 0) {
      timeExceeded = false;
      return "in $hours hours";
    } else {
      timeExceeded = false;
      return "in $hours hours and $minutes minutes";
    }
  }

  String remainingTime() {
    // Current Time
    DateTime now = DateTime.now();

    // Time from Task
    String newTaskTime = getTaskTime();

    DateTime extractedTaskTime = DateFormat('yyyy-MM-dd H:mm')
        .parse('${now.year}-${now.month}-${now.day} $newTaskTime');

    if (!timeExceeded && extractedTaskTime.isBefore(now)) {
      extractedTaskTime = extractedTaskTime.add(const Duration(days: 1));
    } else if (timeExceeded) {
      return "Time Exceeded";
    }

    Duration remainingDuration = extractedTaskTime.difference(now);
    int hours = remainingDuration.inHours;
    int minutes = remainingDuration.inMinutes.remainder(60).abs();

    return formatRemainingTime(hours, minutes);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (!isChecked) {
          setState(() {
            context.read<Placehold>().updateEditStatus(true);
            isEditing = true;
          });
        } else {
          setState(() {
            context
                .read<Placehold>()
                .updatePlaceholder("You cannot change the past.", 2000);
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
        decoration: BoxDecoration(
            color: widget.isLightMode
                ? Colors.grey.shade400
                : const Color.fromARGB(255, 26, 26, 26),
            borderRadius: BorderRadius.circular(15),
            border: isEditing
                ? Border.all(
                    color: widget.isLightMode
                        ? const Color(0xFFAB7D00)
                        : const Color(0xFFD5B858),
                    width: 1,
                  )
                : isChecked
                    ? Border.all(
                        color: widget.isLightMode
                            ? Colors.grey.shade500
                            : const Color.fromARGB(255, 42, 42, 42),
                        width: 1,
                      )
                    : null,

            // Neumorphism
            boxShadow: [
              BoxShadow(
                color: widget.isLightMode
                    ? Colors.grey.shade600
                    : const Color.fromARGB(255, 2, 2, 2),
                offset: isChecked ? const Offset(0, 0) : const Offset(4, 4),
                blurRadius: isChecked ? 0 : 15,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: widget.isLightMode
                    ? Colors.grey.shade300
                    : const Color.fromARGB(255, 42, 42, 42),
                offset: isChecked ? const Offset(0, 0) : const Offset(-3, -3),
                blurRadius: isChecked ? 0 : 15,
                spreadRadius: 0,
              )
            ]),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: hasDate(widget.taskName) ? 0.0 : 5.0,
            top: 5.0,
          ),
          child: Column(
            children: [
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: context.read<Placehold>().isEditing

                      // Editing Text Field
                      ? TextField(
                          autofocus: true,
                          decoration: null,
                          controller: _textEditingController,
                          onChanged: (value) {
                            modifiedTask = value;
                          },
                          onSubmitted: (value) {
                            setState(() {
                              context.read<Placehold>().updateEditStatus(false);
                              isEditing = false;
                            });

                            widget.database.updateTaskName(widget.index, value);
                          },
                          style: GoogleFonts.quicksand(
                            color: widget.isLightMode
                                ? Colors.grey.shade800
                                : const Color.fromARGB(255, 239, 239, 239),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
                          conditionalTaskName(
                              hasDate(widget.taskName), keyword),
                          style: GoogleFonts.quicksand(
                            color: widget.isLightMode
                                ? isChecked
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade900
                                : isChecked
                                    ? Colors.grey.shade500
                                    : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: widget.isLightMode
                                ? Colors.grey.shade800
                                : Colors.white,
                          ),
                        ),
                ),
                trailing: ConfettiWidget(
                  confettiController: controller,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0,
                  gravity: 0.8,
                  maxBlastForce: 50,
                  numberOfParticles: 15,
                  shouldLoop: false,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: isEditing
                        ? MSHCheckbox(
                            size: 32,
                            style: MSHCheckboxStyle.fillScaleColor,
                            duration: const Duration(milliseconds: 1000),
                            colorConfig:
                                MSHColorConfig.fromCheckedUncheckedDisabled(
                              checkedColor: widget.isLightMode
                                  ? const Color(0xFFAB7D00)
                                  : const Color.fromARGB(255, 159, 137, 67),
                            ),
                            value: true,
                            onChanged: (value) {
                              setState(() {
                                context
                                    .read<Placehold>()
                                    .updateEditStatus(false);
                                isEditing = false;
                              });

                              widget.database
                                  .updateTaskName(widget.index, modifiedTask);
                            })
                        : MSHCheckbox(
                            size: 33,
                            style: MSHCheckboxStyle.stroke,
                            duration: const Duration(milliseconds: 500),
                            colorConfig:
                                MSHColorConfig.fromCheckedUncheckedDisabled(
                              checkedColor: widget.isLightMode
                                  ? const Color(0xFFAB7D00)
                                  : const Color(0xFFD5B858),
                              uncheckedColor: widget.isLightMode
                                  ? Colors.grey.shade500
                                  : const Color.fromARGB(255, 93, 93, 93),
                            ),
                            value: isChecked,
                            onChanged: (value) {
                              setState(
                                () {
                                  isChecked = value;
                                  if (isChecked) {
                                    controller.play();

                                    Timer(const Duration(milliseconds: 500),
                                        () {
                                      controller.stop();
                                    });

                                    // Timer(const Duration(milliseconds: 1000), () {
                                    //   context.read<Placehold>().updatePlaceholder(
                                    //         "Woohoo!",
                                    //         1000,
                                    //       );
                                    // });
                                    // context.read<Placehold>().boxChecked("Hi");
                                  } else {
                                    Timer(const Duration(milliseconds: 500),
                                        () {
                                      context
                                          .read<Placehold>()
                                          .updatePlaceholder(
                                            "Oh, nevermind.",
                                            500,
                                          );
                                    });
                                  }
                                },
                              );
                              widget.database.todoList[widget.index][1] =
                                  isChecked;
                              widget.database.updateDatabase();
                            },
                          ),
                  ),
                ),
              ),
              if (hasDate(modifiedTask) && !isChecked)
                Container(
                  width: 400,
                  height: 30,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    color: Color.fromARGB(60, 213, 184, 88),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      remainingTime(),
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

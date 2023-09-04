import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
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
  final bool isMute;

  // Constructor
  const TodoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.deleteFunction,
    required this.index,
    required this.database,
    required this.isLightMode,
    required this.isMute,
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
  String currentTask = '';
  int latestTaskIndex = 0;

  // Time
  bool timeExceeded = false;
  var time = DateTime.now();

  // Edit Task
  bool isEditing = false;
  final TextEditingController _textEditingController = TextEditingController();

  // Audio
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    isChecked = widget.taskCompleted;

    // Confetti
    controller.addListener(() {
      isPlaying = controller.state == ConfettiControllerState.playing;
    });

    currentTask = widget.taskName;
    latestTaskIndex = widget.database.todoList.length - 1;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Current Formatted Time
  String currentTime = DateFormat('hh:mm').format(DateTime.now());

  // Entered Time
  String extractTime(String currentTask) {
    RegExp timePattern = RegExp(r'\b(?:\d{1,2}:)?\d{1,2}:\d{2}\b');
    Match? match = timePattern.firstMatch(currentTask);
    if (match != null) {
      return match.group(0)!; // Time found
    } else {
      return ''; // No time found
    }
  }

  bool hasTime(String currentTask) {
    RegExp timePattern = RegExp(r'\b(?:\d{1,2}:)?\d{1,2}:\d{2}\b');
    return timePattern.hasMatch(currentTask);
  }

// Time Difference
  String calculateTimeDifference() {
    // Is Task Time in PM?
    String taskTime = extractTime(currentTask);
    bool isTaskTimePM = currentTask.toLowerCase().contains('pm');

    // Is Current Time in PM?
    String currentTime = DateFormat('hh:mm a').format(DateTime.now());
    bool isCurrentTimePM = currentTime.toLowerCase().contains('pm');

    // Parsing time strings
    DateTime start = DateFormat('HH:mm').parse(currentTime);
    DateTime end = DateFormat('HH:mm').parse(taskTime);

    Duration difference = end.difference(start);

    // All Cases
    if (difference.isNegative) {
      difference += const Duration(hours: 24);
    } else if (isTaskTimePM && !isCurrentTimePM) {
      difference += const Duration(hours: 12);
    } else if (!isTaskTimePM && isCurrentTimePM) {
      difference += const Duration(hours: 12);
    }

    int hoursLeft = difference.inHours;
    int minutesLeft = difference.inMinutes % 60;

    String formattedTimeDifference;

    // All Other Cases
    if (hoursLeft == 0) {
      if (minutesLeft == 1) {
        formattedTimeDifference = '$minutesLeft minute';
      } else if (minutesLeft > 1) {
        formattedTimeDifference = '$minutesLeft minutes';
      } else {
        formattedTimeDifference = 'Time Exceeded';
        context.read<Placehold>().isTimeExceeded(true);
      }
    } else if (hoursLeft == 1) {
      if (minutesLeft == 0) {
        formattedTimeDifference = 'in $hoursLeft hour';
      } else if (minutesLeft == 1) {
        formattedTimeDifference = 'in $hoursLeft hour and $minutesLeft minute';
      } else {
        formattedTimeDifference = 'in $hoursLeft hour and $minutesLeft minutes';
      }
    } else {
      if (minutesLeft == 0) {
        formattedTimeDifference = 'in $hoursLeft hours';
      } else if (minutesLeft == 1) {
        formattedTimeDifference = 'in $hoursLeft hours and $minutesLeft minute';
      } else {
        formattedTimeDifference =
            'in $hoursLeft hours and $minutesLeft minutes';
      }
    }

    return formattedTimeDifference;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (!isChecked) {
          setState(() {
            context.read<Placehold>().updateEditStatus(true);
            isEditing = true;
            _textEditingController.text = currentTask;

            if (!widget.isMute) {
              player.play(AssetSource('edit.mp3'));
            }
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
        margin: const EdgeInsets.only(left: 25, right: 25, top: 7),
        decoration: BoxDecoration(
            color: widget.index == latestTaskIndex &&
                    context.read<Placehold>().highlightTask
                ? widget.isLightMode
                    ? const Color.fromARGB(255, 201, 201, 201)
                    : const Color.fromARGB(255, 43, 43, 43)
                : widget.isLightMode
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
            bottom: hasTime(widget.taskName) ? 0.0 : 1.0,
            top: 1.0,
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
                            currentTask = value;
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
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
                          currentTask,
                          style: GoogleFonts.quicksand(
                            color: widget.isLightMode
                                ? isChecked
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade900
                                : isChecked
                                    ? Colors.grey.shade500
                                    : Colors.white,
                            fontSize: 16,
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
                  gravity: 0.9,
                  maxBlastForce: 50,
                  numberOfParticles: 30,
                  shouldLoop: false,
                  child: Consumer<Placehold>(
                    builder: (context, placehold, _) {
                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: isEditing
                            ? MSHCheckbox(
                                size: 30,
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

                                  widget.database.updateTaskName(
                                      widget.index, currentTask);
                                },
                              )
                            : MSHCheckbox(
                                size: 30,
                                style: MSHCheckboxStyle.stroke,
                                duration: const Duration(milliseconds: 500),
                                colorConfig:
                                    MSHColorConfig.fromCheckedUncheckedDisabled(
                                  disabledColor: Colors.red,
                                  checkedColor: widget.isLightMode
                                      ? const Color(0xFFAB7D00)
                                      : const Color(0xFFD5B858),
                                  uncheckedColor: widget.isLightMode
                                      ? Colors.grey.shade500
                                      : const Color.fromARGB(255, 93, 93, 93),
                                ),
                                value: isChecked,
                                onChanged: (value) async {
                                  setState(
                                    () {
                                      isChecked = value;

                                      // If Checked
                                      if (isChecked) {
                                        Timer(const Duration(milliseconds: 250),
                                            () {
                                          placehold.updatePlaceholder(
                                            "Woohooo!",
                                            8600,
                                          );
                                        });

                                        // Play Sound
                                        if (!widget.isMute) {
                                          player.play(AssetSource('check.mp3'));
                                        }

                                        // Play Confetti
                                        controller.play();
                                        Timer(const Duration(milliseconds: 500),
                                            () {
                                          controller.stop();
                                        });
                                      }

                                      // If Unchecked
                                      else {
                                        Timer(const Duration(milliseconds: 500),
                                            () {
                                          placehold.updatePlaceholder(
                                            "Oh, nevermind.",
                                            500,
                                          );
                                        });

                                        // Play Sound
                                        if (!widget.isMute) {
                                          player.play(
                                            AssetSource('uncheck.mp3'),
                                          );
                                        }
                                      }
                                    },
                                  );
                                  await player.stop();

                                  widget.database.todoList[widget.index][1] =
                                      isChecked;
                                  widget.database.updateDatabase();
                                },
                              ),
                      );
                    },
                  ),
                ),
              ),
              if (hasTime(currentTask) && !isChecked)
                Container(
                  width: 400,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    color:
                        // context.read<Placehold>().timeExceeded
                        //     ? widget.isLightMode
                        //         ? Color.fromARGB(167, 112, 58, 58)
                        //         : Color.fromARGB(59, 213, 88, 88)
                        //     :
                        widget.isLightMode
                            ? const Color.fromARGB(167, 112, 101, 58)
                            : const Color.fromARGB(60, 213, 184, 88),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      // SHOW TIME DIFFERENCE
                      calculateTimeDifference(),
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

import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Constructor
  const TodoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.deleteFunction,
    required this.index,
    required this.database,
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

  @override
  void initState() {
    super.initState();
    isChecked = widget.taskCompleted;

    // Confetti
    controller.addListener(() {
      isPlaying = controller.state == ConfettiControllerState.playing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24),
      decoration: BoxDecoration(
        color: isChecked
            ? const Color.fromARGB(255, 28, 28, 28)
            : const Color.fromARGB(255, 33, 33, 33),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 5.0,
          top: 5.0,
          left: 10.0,
        ),
        child: ListTile(
          title: Text(
            widget.taskName,
            style: GoogleFonts.quicksand(
              color: isChecked
                  ? Colors.grey
                  : const Color.fromARGB(255, 239, 239, 239),
              fontSize: 19,
              fontWeight: FontWeight.w600,
              decoration:
                  isChecked ? TextDecoration.lineThrough : TextDecoration.none,
              decorationColor: Colors.white,
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
              child: MSHCheckbox(
                size: 33,
                style: MSHCheckboxStyle.stroke,
                duration: const Duration(milliseconds: 500),
                colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                  checkedColor: const Color(0xFFD5B858),
                  uncheckedColor: const Color.fromARGB(255, 93, 93, 93),
                ),
                value: isChecked,
                onChanged: (value) {
                  setState(
                    () {
                      isChecked = value;
                      if (isChecked) {
                        controller.play();

                        Timer(const Duration(milliseconds: 500), () {
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
                        Timer(const Duration(milliseconds: 500), () {
                          context.read<Placehold>().updatePlaceholder(
                                "Oh, nevermind.",
                                1000,
                              );
                        });
                      }

                      widget.database.todoList[widget.index][1] = isChecked;
                      widget.database.updateDatabase();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

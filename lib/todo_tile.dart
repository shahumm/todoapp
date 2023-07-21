import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
// import 'package:hive/hive.dart';
import 'package:todoapp/database.dart';

class TodoTile extends StatefulWidget {
  // Variables
  final String taskName;
  final bool taskCompleted;
  Function(BuildContext)? deleteFunction;
  final int index;
  Database database;
  final Function(String) updateCelebrativeText;

  // Constructor
  TodoTile(
      {super.key,
      required this.taskName,
      required this.taskCompleted,
      required this.deleteFunction,
      required this.index,
      required this.database,
      required this.updateCelebrativeText});

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  // Confetti
  final controller = ConfettiController();
  bool isPlaying = false;
  bool isChecked = false;
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
            ? const Color.fromARGB(255, 29, 29, 29)
            : const Color.fromARGB(255, 33, 33, 33),
        borderRadius: BorderRadius.circular(15), // Adjust the value as needed
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
                size: 30,
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
                      isChecked = !isChecked;
                      if (isChecked && !isPlaying) {
                        controller.play();
                        isPlaying = true;
                        Timer(
                          const Duration(milliseconds: 100),
                          () {
                            controller.stop();
                            isPlaying = false;
                          },
                        );
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
      // ),
    );
  }
}





// child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               child: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: Colors.grey,
//                     width: 2,
//                   ),
//                 ),
//                 child: Transform.scale(
//                   scale: 1.3,
//                   child: MSHCheckbox(
//                     value: isChecked,
//                     onChanged: (value) {
//                       setState(
//                         () {
//                           isChecked = !isChecked;
//                           if (isChecked && !isPlaying) {
//                             controller.play();
//                             isPlaying = true;
//                             Timer(
//                               const Duration(milliseconds: 100),
//                               () {
//                                 controller.stop();
//                                 isPlaying = false;
//                               },
//                             );
//                           }
//                           widget.database.todoList[widget.index][1] = isChecked;
//                           widget.database.updateDatabase();
//                         },
//                       );
//                     },
//                     // shape: RoundedRectangleBorder(
//                     //   borderRadius: BorderRadius.circular(6),
//                     // ),
//                     // checkColor: const Color(0xFFD5B858),
//                     // fillColor: MaterialStateProperty.resolveWith(
//                     //   (states) {
//                     //     if (states.contains(MaterialState.selected)) {
//                     //       return Colors.transparent;
//                     //     } else {
//                     //       return Colors.transparent;
//                     //     }
//                     //   },
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       // ),
//     );
//   }
// }

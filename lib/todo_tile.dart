import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// class TodoTile extends StatelessWidget {
//   // Variables
//   final String taskName;
//   final bool taskCompleted;
//   final Function(bool?)? onChanged;

//   // Constructor
//   const TodoTile(
//       {super.key,
//       required this.taskName,
//       required this.taskCompleted,
//       required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(left: 24, right: 24),
//       decoration: BoxDecoration(
//         color: taskCompleted
//             ? const Color.fromARGB(255, 27, 27, 27)
//             : const Color.fromARGB(255, 31, 31, 31),
//         borderRadius: BorderRadius.circular(15), // Adjust the value as needed
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 5.0, top: 5.0),
//         child: ListTile(
//           title: Text(
//             taskName,
//             style: GoogleFonts.quicksand(
//               color: taskCompleted
//                   ? Colors.grey
//                   : const Color.fromARGB(255, 239, 239, 239),
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               decoration: taskCompleted
//                   ? TextDecoration.lineThrough
//                   : TextDecoration.none,
//               decorationColor: Colors.white,
//             ),
//           ),
//           trailing: Transform.scale(
//             scale: 1.6,
//             // child: Checkbox(
//             //   value: taskCompleted,
//             //   onChanged: onChanged,
//             //   shape: RoundedRectangleBorder(
//             //     borderRadius: BorderRadius.circular(6),
//             //   ),
//             //   checkColor: const Color(0xFFD5B858),
//             //   fillColor: MaterialStateProperty.resolveWith((states) {
//             //     if (states.contains(MaterialState.selected)) {
//             //       return const Color.fromARGB(255, 27, 27, 27);
//             //     } else {
//             //       return const Color.fromARGB(255, 227, 227, 227);
//             //     }
//             //   }),

//             child: MSHCheckbox(
//               size: 20,
//               duration: const Duration(milliseconds: 1500),
//               value: taskCompleted,
//               onChanged: (selected) => onChanged?.call(selected),
//               colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
//                 checkedColor: const Color(0xFFD5B858),
//               ),
//               style: MSHCheckboxStyle.stroke,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class TodoTile extends StatefulWidget {
  // Variables
  final String taskName;
  final bool taskCompleted;
  final Function(bool?)? onChanged;

  // Constructor
  const TodoTile(
      {super.key,
      required this.taskName,
      required this.taskCompleted,
      required this.onChanged});

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.taskCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24),
      decoration: BoxDecoration(
        color: widget.taskCompleted
            ? const Color.fromARGB(255, 27, 27, 27)
            : const Color.fromARGB(255, 31, 31, 31),
        borderRadius: BorderRadius.circular(15), // Adjust the value as needed
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5.0, top: 5.0, left: 10),
        child: ListTile(
          title: Text(
            widget.taskName,
            style: GoogleFonts.quicksand(
              color: widget.taskCompleted
                  ? Colors.grey
                  : const Color.fromARGB(255, 239, 239, 239),
              fontSize: 19,
              fontWeight: FontWeight.w600,
              decoration: widget.taskCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              decorationColor: Colors.white,
            ),
          ),
          trailing: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey,
                width: 2,
              ),
            ),
            child: Transform.scale(
              scale: 1.4,
              child: Checkbox(
                value: widget.taskCompleted,
                onChanged: widget.onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                checkColor: const Color(0xFFD5B858),
                fillColor: MaterialStateProperty.resolveWith(
                  (states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.transparent;
                    } else {
                      return Colors.transparent;
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

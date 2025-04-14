import 'package:flutter/material.dart';

class bookInfoRow extends StatelessWidget {
  bookInfoRow(
      {super.key, required this.icon, required this.title, required this.info});

  final Widget icon;
  final String title;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the top
        children: [
          icon,
          SizedBox(width: 8),
          Text(title),
          Spacer(),
          Expanded( // Prevents overflow by wrapping text
            child: Text(
              info,
              textAlign: TextAlign.right, // Align text to the right
              overflow: TextOverflow.visible, // Allows text to wrap
              softWrap: true, // Ensures it moves to the next line if needed
            ),
          ),
        ],
      ),
    );
  }
}

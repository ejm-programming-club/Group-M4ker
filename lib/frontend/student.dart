import 'package:flutter/material.dart';

class StudentEntry extends StatelessWidget {
  final bool isSelected;
  final bool isHighlighted;
  final String studentName;
  final VoidCallback onTapCallback;

  static final Color selectedColor = Colors.lightBlue[300];
  static final Color highlightedColor = Colors.lightGreenAccent[300];

  const StudentEntry(
      {Key key,
      this.isSelected,
      this.isHighlighted,
      this.studentName,
      this.onTapCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Chip(
        label: Text(studentName),
        backgroundColor: isSelected
            ? selectedColor
            : isHighlighted ? highlightedColor : null,
      ),
      onTap: onTapCallback,
    );
  }
}

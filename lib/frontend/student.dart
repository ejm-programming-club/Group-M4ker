import 'package:flutter/material.dart';

class StudentEntry extends StatelessWidget {
  final bool isSelected;
  final bool isHighlighted;
  final String studentName;
  final VoidCallback onTapCallback;

  static final Color selectedColor = Colors.lightBlue[100];

  const StudentEntry(
      {Key key,
      this.isSelected,
      this.isHighlighted,
      this.studentName,
      this.onTapCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
      child: new Text(
        studentName,
        style: TextStyle(
          fontWeight: isHighlighted ? FontWeight.w900 : null,
        ),
      ),
      onPressed: onTapCallback,
      splashColor: isSelected ? null : selectedColor,
      color: isSelected ? selectedColor : null,
    );
  }
}

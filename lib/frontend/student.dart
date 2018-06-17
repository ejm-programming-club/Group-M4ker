import 'package:flutter/material.dart';

class StudentEntry extends StatelessWidget {
  final bool isSelected;
  final bool isHighlighted;
  final String studentName;
  final VoidCallback onTapCallback;

  static final Color selectedColor = Colors.lightBlue[200];

  const StudentEntry({
    Key key,
    this.isSelected,
    this.isHighlighted,
    this.studentName,
    this.onTapCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: isHighlighted ? selectedColor : Colors.white,
        ),
      ),
      child: FlatButton(
        child: Text(
          studentName,
        ),
        onPressed: onTapCallback,
        splashColor: isSelected ? null : selectedColor,
        color: isSelected ? selectedColor : null,
      ),
    );
  }
}

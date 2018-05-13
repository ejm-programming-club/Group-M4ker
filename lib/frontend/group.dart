import 'package:flutter/material.dart';
import 'package:correze_grouper/backend/utils.dart';
import 'package:correze_grouper/frontend/student.dart';

typedef void OnStudentSelectCallback(StudentPos pos);

class GroupBox extends StatelessWidget {
  final int groupInd;
  final List<Student> members;
  final List<String> issues;
  final OnStudentSelectCallback onStudentSelectCallback;
  final List<StudentPos> selectedPositions;
  final List<StudentPos> highlightedPositions;

  const GroupBox(
      {Key key,
      this.members,
      this.onStudentSelectCallback,
      this.selectedPositions,
      this.highlightedPositions,
      this.groupInd,
      this.issues})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height / 3,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: members.asMap().entries.map(
            (MapEntry<int, Student> member) {
              List<String> name = member.value.name.split(' ');
              var firstName = name.last;
              var abbreviatedLastName = name.first[0] + '.';
              return StudentEntry(
                studentName: "$firstName $abbreviatedLastName",
                isSelected: selectedPositions
                    .contains(StudentPos(groupInd, member.key)),
                isHighlighted: highlightedPositions
                    .contains(StudentPos(groupInd, member.key)),
                onTapCallback: () =>
                    onStudentSelectCallback(StudentPos(groupInd, member.key)),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
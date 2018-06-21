import 'package:flutter/material.dart';
import 'package:group_m4ker/backend/utils.dart';
import 'package:group_m4ker/frontend/student.dart';

typedef void OnStudentSelectCallback(StudentPos pos);

class GroupBox extends StatelessWidget {
  final int groupInd;
  final List<Student> members;
  final List<String> issues;
  final OnStudentSelectCallback onStudentSelectCallback;
  final List<StudentPos> selectedPositions;
  final List<StudentPos> highlightedPositions;

  const GroupBox({
    Key key,
    this.members,
    this.onStudentSelectCallback,
    this.selectedPositions,
    this.highlightedPositions,
    this.groupInd,
    this.issues,
  }) : super(key: key);

  String viewStats(GroupStats stats) {
    return [
      "M: ${stats.maleCount}",
      "F: ${stats.femaleCount}",
      "Bio: ${stats.bioCount}",
      "Chm: ${stats.chmCount}",
      "Phy: ${stats.phyCount}",
      "SL: ${stats.slCount}",
      "HL: ${stats.hlCount}",
      "Leaders: ${stats.strongLeadersCount}",
    ].join("\n");
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height / 2.75,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Container(
              padding: new EdgeInsets.only(top: 4.0, bottom: 4.0),
              decoration: new BoxDecoration(
                  border: new Border.all(
                color: issues.isEmpty
                    ? Colors.green[400] //Color(0x00000000) // transparent
                    : Colors.redAccent[200],
                width: 2.0,
              )),
              child: Tooltip(
                child: Text(
                  "Group ${String.fromCharCode(65 + groupInd)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                message: (issues.isEmpty
                        ? ""
                        : issues.map((String s) => "❌ $s").join("\n") + "\n") +
                    viewStats(GroupStats.of(members)),
                preferBelow: false,
              ),
            ),
            Divider(
              height: 1.0,
            ),
            Expanded(
              child: new Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
                child: ListView(
                  children: members
                      .asMap()
                      .entries
                      .map((MapEntry<int, Student> member) {
                    List<String> name = member.value.name.split(' ');
                    var firstName = name.last;
                    var abbreviatedLastName =
                        name.first.isEmpty || name.length < 2
                            ? ''
                            : name.first[0] + '.';
                    return StudentEntry(
                      studentName: "$firstName $abbreviatedLastName",
                      isSelected: selectedPositions
                          .contains(StudentPos(groupInd, member.key)),
                      isHighlighted: highlightedPositions
                          .contains(StudentPos(groupInd, member.key)),
                      onTapCallback: () => onStudentSelectCallback(
                          StudentPos(groupInd, member.key)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

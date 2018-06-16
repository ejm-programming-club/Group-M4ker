import 'package:flutter/material.dart';
import 'package:group_m4ker/backend/utils.dart';

class PromoEditor extends StatefulWidget {
  final Promo promo;

  const PromoEditor({Key key, this.promo}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PromoEditorState(
        promo.students..sort((s1, s2) => s1.name.compareTo(s2.name)),
      );
}

class _PromoEditorState extends State<PromoEditor> {
  // TODO save promo
  // TODO allow deletion of student
  // TODO allow addition of student
  // TODO allow edition  of student's name (on Selected)
  List<Student> students;
  int sortedColumnIndex = 0;
  bool sortedAscending = true;
  String selectedName;

  _PromoEditorState(this.students);

  void sortStudents(int columnIndex, bool ascending) {
    Comparable property(Student student) {
      return {
        0: student.name,
        1: student.profile.gender.index,
        2: student.profile.isStrongLeader ? 1 : 0,
        3: student.profile.bioLevel?.index ?? -1,
        4: student.profile.chmLevel?.index ?? -1,
        5: student.profile.phyLevel?.index ?? -1,
      }[columnIndex];
    }

    setState(() {
      if (columnIndex == sortedColumnIndex) {
        sortedAscending = !sortedAscending;
      } else {
        sortedColumnIndex = columnIndex;
        sortedAscending = true;
      }
      students.sort(
        (Student s1, Student s2) => property(s1) == property(s2)
            ? s1.name.compareTo(s2.name)
            : property(s1).compareTo(property(s2)),
      );
      if (!ascending) students = students.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      sortAscending: sortedAscending,
      sortColumnIndex: sortedColumnIndex,
      columns: <DataColumn>[
        DataColumn(
          label: Text("Name"),
          numeric: false,
          onSort: sortStudents,
        ),
        DataColumn(
          label: Text("Gender"),
          numeric: false,
          onSort: sortStudents,
        ),
        DataColumn(
          label: Text("Leadership"),
          numeric: false,
          onSort: sortStudents,
        ),
        DataColumn(
          label: Text("Biology"),
          numeric: false,
          onSort: sortStudents,
        ),
        DataColumn(
          label: Text("Chemistry"),
          numeric: false,
          onSort: sortStudents,
        ),
        DataColumn(
          label: Text("Physics"),
          numeric: false,
          onSort: sortStudents,
        ),
      ],
      rows: students
          .map((student) => DataRow(
                selected: student.name == selectedName,
                cells: [
                  DataCell(
                    Text(student.name),
                    onTap: () => setState(() {
                          selectedName = student.name == selectedName
                              ? null
                              : student.name;
                        }),
                  ),
                  DataCell(
                    Text(student.profile.gender.toString().split('.').last),
                    onTap: () => setState(() {
                          student.profile.gender =
                              student.profile.gender == Gender.M
                                  ? Gender.F
                                  : Gender.M;
                        }),
                  ),
                  DataCell(
                    Icon(student.profile.isStrongLeader ? Icons.check : null),
                    onTap: () => setState(() {
                          student.profile.isStrongLeader =
                              !student.profile.isStrongLeader;
                        }),
                  ),
                  DataCell(
                    Text(student.profile.bioLevel != null
                        ? student.profile.bioLevel.toString().split('.').last
                        : ""),
                    onTap: () => setState(() {
                          student.profile.bioLevel =
                              student.profile.bioLevel == null
                                  ? Level.SL
                                  : student.profile.bioLevel == Level.SL
                                      ? Level.HL
                                      : null;
                        }),
                  ),
                  DataCell(
                    Text(student.profile.chmLevel != null
                        ? student.profile.chmLevel.toString().split('.').last
                        : ""),
                    onTap: () => setState(() {
                          student.profile.chmLevel =
                              student.profile.chmLevel == null
                                  ? Level.SL
                                  : student.profile.chmLevel == Level.SL
                                      ? Level.HL
                                      : null;
                        }),
                  ),
                  DataCell(
                    Text(student.profile.phyLevel != null
                        ? student.profile.phyLevel.toString().split('.').last
                        : ""),
                    onTap: () => setState(() {
                          student.profile.phyLevel =
                              student.profile.phyLevel == null
                                  ? Level.SL
                                  : student.profile.phyLevel == Level.SL
                                      ? Level.HL
                                      : null;
                        }),
                  ),
                ],
              ))
          .toList(),
    );
  }
}

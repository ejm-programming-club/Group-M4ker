import 'package:flutter/material.dart';
import 'package:group_m4ker/backend/utils.dart';
import 'package:group_m4ker/frontend/dialogs.dart';

class PromoEditor extends StatefulWidget {
  final Promo promo;
  final ArgCallback<Promo> onSave;

  const PromoEditor({Key key, this.promo, this.onSave}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PromoEditorState(
        promo.students..sort((s1, s2) => s1.name.compareTo(s2.name)),
      );
}

class _PromoEditorState extends State<PromoEditor> {
  List<Student> students;
  int sortedColumnIndex = 0;
  bool sortedAscending = true;
  Student selectedStudent;
  bool edited = false;

  _PromoEditorState(this.students);

  void sortStudents(int columnIndex, bool ascending) {
    Comparable property(Student student) {
      return {
        0: student.name,
        1: student.profile.gender?.index ?? -1,
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
    return Column(
      children: <Widget>[
        ButtonBar(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.indeterminate_check_box),
              tooltip: "Remove selected student",
              onPressed: selectedStudent == null
                  ? null
                  : () => setState(() {
                        students.remove(selectedStudent);
                        edited = true;
                        selectedStudent = null;
                      }),
            ),
            IconButton(
              icon: Icon(Icons.add_box),
              tooltip: "Add new student",
              onPressed: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      final controller = TextEditingController();
                      return AlertDialog(
                        title: Text("Name of student"),
                        content: TextField(
                          controller: controller,
                          autofocus: true,
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("CANCEL"),
                            textColor: Colors.red,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          FlatButton(
                            child: Text("ADD"),
                            onPressed: () {
                              setState(() {
                                final newStudent = Student(
                                  name: controller.text,
                                  profile: Profile(
                                    isStrongLeader: false,
                                    gender: null,
                                    bioLevel: null,
                                    chmLevel: null,
                                    phyLevel: null,
                                  ),
                                );
                                edited = true;
                                sortedColumnIndex = null;
                                selectedStudent = newStudent;
                                students.insert(0, newStudent);
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
            IconButton(
              icon: Icon(Icons.edit),
              tooltip: "Rename selected student",
              onPressed: selectedStudent == null
                  ? null
                  : () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            final controller = TextEditingController
                                .fromValue(TextEditingValue(
                              text: selectedStudent.name,
                              selection: TextSelection(
                                baseOffset: 0,
                                extentOffset: selectedStudent.name.length,
                              ),
                            ));
                            return AlertDialog(
                              title: Text("Name of student"),
                              content: TextField(
                                controller: controller,
                                autofocus: true,
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("CANCEL"),
                                  textColor: Colors.red,
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                FlatButton(
                                  child: Text("DONE"),
                                  onPressed: () {
                                    setState(() {
                                      selectedStudent.name = controller.text;
                                      edited = true;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    },
            ),
            FlatButton(
              child: Text("CANCEL"),
              textColor: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("UPDATE CLASS"),
              textColor: Colors.blue,
              onPressed: edited
                  ? () {
                      widget.onSave(Promo(students));
                      Navigator.of(context).pop();
                    }
                  : null,
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.66,
          width: MediaQuery.of(context).size.width * 0.9,
          child: ListView(
            children: <Widget>[
              DataTable(
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
                          selected: student == selectedStudent,
                          cells: [
                            DataCell(
                              Text(student.name),
                              onTap: () => setState(() {
                                    selectedStudent = student == selectedStudent
                                        ? null
                                        : student;
                                  }),
                            ),
                            DataCell(
                              Text(student.profile.gender
                                  .toString()
                                  .split('.')
                                  .last),
                              onTap: () => setState(() {
                                    student.profile.gender =
                                        student.profile.gender == Gender.M
                                            ? Gender.F
                                            : Gender.M;
                                    edited = true;
                                  }),
                            ),
                            DataCell(
                              Icon(student.profile.isStrongLeader
                                  ? Icons.check
                                  : null),
                              onTap: () => setState(() {
                                    student.profile.isStrongLeader =
                                        !student.profile.isStrongLeader;
                                    edited = true;
                                  }),
                            ),
                            DataCell(
                              Text(student.profile.bioLevel != null
                                  ? student.profile.bioLevel
                                      .toString()
                                      .split('.')
                                      .last
                                  : ""),
                              onTap: () => setState(() {
                                    student.profile.bioLevel =
                                        student.profile.bioLevel == null
                                            ? Level.SL
                                            : student.profile.bioLevel ==
                                                    Level.SL
                                                ? Level.HL
                                                : null;
                                    edited = true;
                                  }),
                            ),
                            DataCell(
                              Text(student.profile.chmLevel != null
                                  ? student.profile.chmLevel
                                      .toString()
                                      .split('.')
                                      .last
                                  : ""),
                              onTap: () => setState(() {
                                    student.profile.chmLevel =
                                        student.profile.chmLevel == null
                                            ? Level.SL
                                            : student.profile.chmLevel ==
                                                    Level.SL
                                                ? Level.HL
                                                : null;
                                    edited = true;
                                  }),
                            ),
                            DataCell(
                              Text(student.profile.phyLevel != null
                                  ? student.profile.phyLevel
                                      .toString()
                                      .split('.')
                                      .last
                                  : ""),
                              onTap: () => setState(() {
                                    student.profile.phyLevel =
                                        student.profile.phyLevel == null
                                            ? Level.SL
                                            : student.profile.phyLevel ==
                                                    Level.SL
                                                ? Level.HL
                                                : null;
                                    edited = true;
                                  }),
                            ),
                          ],
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

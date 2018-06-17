import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:group_m4ker/backend/evaluator.dart';
import 'package:group_m4ker/backend/generator.dart';
import 'package:group_m4ker/backend/utils.dart';
import 'package:group_m4ker/frontend/dialogs.dart';
import 'package:group_m4ker/frontend/drive.dart';
import 'package:group_m4ker/frontend/editor.dart';
import 'package:group_m4ker/frontend/group.dart';
import 'package:path_provider/path_provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.teal,
      ),
      title: "Group M4ker",
      home: Grouper(),
    );
  }
}

class Grouper extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GrouperState();
}

class _GrouperState extends State<Grouper> {
  Promo _promo;

  Promo get promo => _promo;

  set promo(Promo promo) {
    setState(() {
      _promo = promo;
      evaluator = MeanEvaluator(promo);
      generator = MinJealousyGenerator(promo);
    });
  }

  _GrouperState() {
    loadPromo();
  }

  Evaluator evaluator;
  Generator generator;

  int groupCount = 10;
  Subject excludedSubject;

  Grouping grouping = Grouping([]);
  List<List<String>> issues = [];

  List<StudentPos> selectedPositions = [];
  List<StudentPos> highlightedPositions = [];

  Student queryStudent = Student(
    name: "",
    profile: Profile(
        isStrongLeader: false,
        gender: null,
        bioLevel: null,
        chmLevel: null,
        phyLevel: null),
  );
  final queryNameController = TextEditingController();

  List<List<StudentPos>> swapHistory = [];
  int swapHistoryPointer = -1;

  String loadedFilename;

  void generateGroups() {
    setState(() {
      grouping = generator.generate(
        numberOfGroups: groupCount,
      );
      issues = evaluator.findIssues(grouping);
      selectedPositions = [];
      highlightedPositions = [];

      swapHistory.clear();
      swapHistoryPointer = -1;
    });
  }

  void select(StudentPos pos) {
    setState(() {
      if (selectedPositions.contains(pos))
        selectedPositions.remove(pos);
      else {
        if (selectedPositions.length == 2)
          selectedPositions.clear();
        else
          selectedPositions.add(pos);
      }

      if (selectedPositions.isNotEmpty) {
        int queryGroup = selectedPositions.last.groupInd;
        int queryMember = selectedPositions.last.memberInd;
        queryStudent = grouping.groups[queryGroup][queryMember].copy();
        queryNameController.text = queryStudent.name;
      } else {
        queryStudent = Student(
            name: "",
            profile: Profile(
              isStrongLeader: false,
              gender: null,
              bioLevel: null,
              chmLevel: null,
              phyLevel: null,
            ));
        queryNameController.clear();
      }

      if (selectedPositions.length == 1) {
        highlightedPositions = locateQuery();
      } else {
        highlightedPositions = [];
      }
    });
  }

  void swap() {
    setState(() {
      grouping.swap(selectedPositions[0], selectedPositions[1]);
      issues = evaluator.findIssues(grouping);

      swapHistory.removeRange(++swapHistoryPointer, swapHistory.length);
      swapHistory.add([selectedPositions[0], selectedPositions[1]]);
    });
  }

  void undoSwap() {
    setState(() {
      selectedPositions = [
        swapHistory[swapHistoryPointer].first,
        swapHistory[swapHistoryPointer].last,
      ];
      grouping.swap(selectedPositions[0], selectedPositions[1]);
      issues = evaluator.findIssues(grouping);
      swapHistoryPointer--;
    });
  }

  void redoSwap() {
    setState(() {
      swapHistoryPointer++;
      selectedPositions = [
        swapHistory[swapHistoryPointer].first,
        swapHistory[swapHistoryPointer].last,
      ];
      grouping.swap(selectedPositions[0], selectedPositions[1]);
      issues = evaluator.findIssues(grouping);
    });
  }

  void exclude(Subject subject) {
    setState(() {
      excludedSubject = subject;
      Promo newPromo = Promo(
        promo.students.where((student) => !student.takes(subject)).toList(),
      );
      generator.promo = newPromo;
      evaluator.promo = newPromo;
    });
  }

  void load(BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    List<String> saves;

    Directory("$path/state").createSync();
    final file = File("$path/state/saved.json");
    try {
      saves = (jsonDecode(await file.readAsString()) as List)
          .cast<String>()
          .toList();
    } catch (e) {
      saves = [];
    }

    showDialog(
        context: context,
        builder: (BuildContext context) => LoadDialog(
              context: context,
              filenames: saves,
              onConfirm: readFrom,
              onDelete: (String deletedFileName) {
                saves.remove(deletedFileName);
                File("$path/$deletedFileName").delete();
                file.writeAsString(jsonEncode(saves));
              },
            ));
  }

  void save(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => SaveDialog(
              context: context,
              defaultName: loadedFilename,
              onConfirm: writeTo,
            ));
  }

  void writeTo(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    List<String> saves;
    final file = File("$path/$filename");
    await file.writeAsString(
      '''{"excluded": "${excludedSubject
          .toString()
          .split(".")
          .last}", 
  "groups": ${grouping.toString()}
}''',
    );

    Directory("$path/state").createSync();
    final savesFile = File("$path/state/saved.json");
    try {
      saves = (jsonDecode(await savesFile.readAsString()) as List)
          .cast<String>()
          .toList();
    } catch (e) {
      saves = [];
    }
    if (!saves.contains(filename)) saves.add(filename);
    await savesFile.writeAsString(jsonEncode(saves));
  }

  void readFrom(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    final file = File("$path/$filename");
    String jsonString = await file.readAsString();
    Map<String, dynamic> jsonInfo = jsonDecode(jsonString);

    excludedSubject = {
      "BIO": Subject.BIO,
      "CHM": Subject.CHM,
      "PHY": Subject.PHY,
    }[jsonInfo["excluded"]];

    setState(() {
      loadedFilename = filename;

      grouping =
          Grouping.fromList(listOfGroups: jsonInfo["groups"], promo: promo);
      exclude(excludedSubject);
      groupCount = grouping.groups.length;
      issues = evaluator.findIssues(grouping);
    });
  }

  List<StudentPos> locateQuery() {
    List<StudentPos> positions = [];
    for (int groupInd = 0; groupInd < grouping.groups.length; groupInd++) {
      for (int memberInd = 0;
          memberInd < grouping.groups[groupInd].length;
          memberInd++) {
        Student student = grouping.groups[groupInd][memberInd];
        if (student.profile == queryStudent.profile ||
            (queryStudent.name.isNotEmpty &&
                student.name
                    .toLowerCase()
                    .contains(queryStudent.name.toLowerCase()))) {
          positions.add(StudentPos(groupInd, memberInd));
        }
      }
    }
    return positions;
  }

  @override
  Widget build(BuildContext context) {
    List<GroupBox> groupBoxes = grouping.groups
        .asMap()
        .entries
        .map((MapEntry<int, List<Student>> group) => GroupBox(
              groupInd: group.key,
              issues: issues[group.key],
              members: group.value,
              selectedPositions: selectedPositions,
              highlightedPositions: highlightedPositions,
              onStudentSelectCallback: select,
            ))
        .toList();
    List<Widget> groupColumns = [];
    for (int i = 0; i < groupBoxes.length; i += 2) {
      groupColumns.add(Column(
        children: groupBoxes.sublist(i, min(i + 2, groupBoxes.length)),
      ));
    }
    if (groupColumns.isEmpty) {
      TextStyle headerStyle = TextStyle(fontSize: 32.0);
      TextStyle contentStyle = TextStyle(fontSize: 24.0);
      List<Widget> information = [];

      const ICON_PADDING = 8.0;

      var iconGenerator = (Icon icon) =>
          new Padding(padding: const EdgeInsets.all(ICON_PADDING), child: icon);

      final warningIcon = iconGenerator(Icon(
        Icons.warning,
        color: Colors.red,
      ));

      final allGoodIcon = iconGenerator(Icon(
        Icons.check_box,
        color: Colors.green,
      ));

      final infoIcon = iconGenerator(Icon(
        Icons.info,
        color: Colors.blue,
      ));

      if (promo == null) {
        information.add(Row(
          children: <Widget>[
            warningIcon,
            Text(
              "No class information loaded",
              style: headerStyle,
            ),
          ],
        ));
      } else {
        information.add(Row(
          children: <Widget>[
            allGoodIcon,
            Text(
              "Class information is loaded",
              style: headerStyle,
            )
          ],
        ));
      }
      information.add(Row(
        children: <Widget>[
          Text("Go to ", style: contentStyle),
          SizedBox(width: 5.0),
          Icon(Icons.menu),
          SizedBox(width: 5.0),
          Text(" at the top left to:", style: contentStyle),
          new Divider(height: 2.0),
        ],
      ));
      information.add(Row(children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.sync),
                SizedBox(width: 5.0),
                Text("Load class information from google spreadsheet",
                    style: contentStyle)
              ],
            ),
            new Divider(height: 2.0),
            Row(
              children: <Widget>[
                Icon(Icons.group),
                SizedBox(width: 5.0),
                Text("View / edit class information", style: contentStyle)
              ],
            ),
            new Divider(height: 2.0),
            Row(
              children: <Widget>[
                Icon(Icons.settings),
                SizedBox(width: 5.0),
                Text("Tweak grouping parameters (number of groups)",
                    style: contentStyle)
              ],
            ),
          ],
        ),
      ]));
      information.add(Divider());
      information.add(Row(
        children: <Widget>[
          warningIcon,
          Text(
            "No grouping loaded",
            style: headerStyle,
          ),
        ],
      ));
      information.add(Row(children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Go to button bar at the bottom to:",
              style: contentStyle,
            ),
            new Divider(height: 2.0),
            Row(
              children: <Widget>[
                Icon(Icons.refresh),
                SizedBox(width: 5.0),
                Text("Generate new groups", style: contentStyle),
              ],
            ),
            new Divider(height: 2.0),
            Row(
              children: <Widget>[
                Icon(Icons.file_upload),
                SizedBox(width: 5.0),
                Text("Load saved grouping", style: contentStyle)
              ],
            ),
            new Divider(height: 2.0),
            Row(
              children: <Widget>[
                Icon(Icons.file_download),
                SizedBox(width: 5.0),
                Text("Save current grouping", style: contentStyle)
              ],
            ),
            new Divider(height: 2.0),
            Row(
              children: <Widget>[
                Icon(Icons.swap_horiz),
                SizedBox(width: 5.0),
                Icon(Icons.undo),
                SizedBox(width: 5.0),
                Icon(Icons.redo),
                SizedBox(width: 5.0),
                Text("Do, undo, and redo student swapping", style: contentStyle)
              ],
            ),
          ],
        ),
      ]));
      information.add(Divider());
      information.add(Row(
        children: <Widget>[
          infoIcon,
          Text(
            "Use the top bar to filter students",
            style: headerStyle,
          ),
        ],
      ));
      groupColumns.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: information,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Group M4ker"),
      ),
      body: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: TextField(
                      controller: queryNameController,
                      decoration: InputDecoration(
                        helperText: "Student name",
                      ),
                      onChanged: (String name) {
                        setState(() {
                          queryStudent.name = name;
                          queryStudent.profile = Profile(
                            isStrongLeader: false,
                            gender: null,
                            bioLevel: null,
                            chmLevel: null,
                            phyLevel: null,
                          );
                          highlightedPositions = locateQuery();
                        });
                      },
                    ),
                  ),
                  DropdownButton<Gender>(
                    value: queryStudent.profile.gender,
                    items: [
                      DropdownMenuItem<Gender>(
                        child: Text("M/F"),
                        value: null,
                      ),
                      DropdownMenuItem<Gender>(
                        child: Chip(
                          label: Text(
                            "M",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.blueAccent[200],
                        ),
                        value: Gender.M,
                      ),
                      DropdownMenuItem<Gender>(
                        child: Chip(
                          label: Text(
                            "F",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.pinkAccent[200],
                        ),
                        value: Gender.F,
                      ),
                    ],
                    onChanged: (Gender gender) {
                      setState(() {
                        queryNameController.clear();
                        queryStudent.profile.gender = gender;
                        highlightedPositions = locateQuery();
                      });
                    },
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 6,
                    child: CheckboxListTile(
                      title: Text("Leadership"),
                      dense: true,
                      value: queryStudent.profile.isStrongLeader,
                      onChanged: (bool isStrongLeader) {
                        setState(() {
                          queryStudent.profile.isStrongLeader = isStrongLeader;
                          highlightedPositions = locateQuery();
                          queryNameController.clear();
                        });
                      },
                    ),
                  ),
                ] +
                Subject.values.map((Subject s) {
                  Color backgroundColor = {
                    Subject.BIO: Color.fromRGBO(247, 135, 60, 0.9),
                    Subject.CHM: Color.fromRGBO(127, 67, 63, 0.9),
                    Subject.PHY: Color.fromRGBO(124, 20, 2, 0.9),
                  }[s];
                  return DropdownButton<Level>(
                    value: {
                      Subject.BIO: queryStudent.profile.bioLevel,
                      Subject.CHM: queryStudent.profile.chmLevel,
                      Subject.PHY: queryStudent.profile.phyLevel,
                    }[s],
                    items: [null, Level.SL, Level.HL].map((Level lv) {
                      return DropdownMenuItem<Level>(
                        value: lv,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Chip(
                              label: Text(
                                s.toString().split(".").last,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: backgroundColor,
                            ),
                            {
                              null: Icon(
                                Icons.not_interested,
                                color: Colors.red,
                              ),
                              Level.SL: Chip(
                                label: Text(
                                  "SL",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.blue[400],
                              ),
                              Level.HL: Chip(
                                label: Text(
                                  "HL",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.blueGrey[400],
                              ),
                            }[lv],
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Level lv) {
                      if (s == Subject.BIO) queryStudent.profile.bioLevel = lv;
                      if (s == Subject.CHM) queryStudent.profile.chmLevel = lv;
                      if (s == Subject.PHY) queryStudent.profile.phyLevel = lv;
                      setState(() {
                        highlightedPositions = locateQuery();
                        queryNameController.clear();
                      });
                    },
                  );
                }).toList(),
          ),
          Row(
            children: groupColumns,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text("Grouping parameters"),
              leading: Icon(Icons.settings),
            ),
            Divider(),
            ListTile(
              title: Text("Number of groups"),
              subtitle: Slider(
                value: groupCount.toDouble(),
                min: 2.0,
                max: 10.0,
                divisions: 8,
                onChanged: (double value) {
                  setState(() {
                    groupCount = value.toInt();
                  });
                },
                label: groupCount.toString(),
              ),
            ),
            ListTile(
              title: Text("Redistribute without ..."),
              subtitle: Column(
                children: <Widget>[
                  RadioListTile<Subject>(
                    value: null,
                    groupValue: excludedSubject,
                    onChanged: exclude,
                    title: Text("None"),
                  ),
                  RadioListTile<Subject>(
                    value: Subject.BIO,
                    groupValue: excludedSubject,
                    onChanged: exclude,
                    title: Text("Biologists"),
                  ),
                  RadioListTile<Subject>(
                    value: Subject.CHM,
                    groupValue: excludedSubject,
                    onChanged: exclude,
                    title: Text("Chemists"),
                  ),
                  RadioListTile<Subject>(
                    value: Subject.PHY,
                    groupValue: excludedSubject,
                    onChanged: exclude,
                    title: Text("Physicists"),
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
                title: Text("Load class from Drive"),
                leading: Icon(
                  Icons.sync,
                  color: promo == null ? Colors.teal : null,
                ),
                onTap: () {
                  driveSignIn(context, loadPromo);
                }),
            Divider(),
            ListTile(
              title: Text("View / Edit class"),
              leading: Icon(
                Icons.group,
                color: promo != null ? Colors.teal : null,
              ),
              onTap: promo != null
                  ? () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog(
                              title: Text("Class"),
                              content: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: PromoEditor(
                                  promo: promo,
                                  onSave: (Promo newPromo) {
                                    setState(() {
                                      promo = newPromo;
                                      savePromo();
                                      exclude(excludedSubject);

                                      grouping = Grouping([]);
                                      selectedPositions = [];
                                      issues = [];
                                    });
                                  },
                                ),
                              ),
                            ),
                      );
                    }
                  : null,
            ),
            Divider(),
          ],
        ),
      ),
      persistentFooterButtons: <Widget>[
        IconButton(
          icon: Icon(Icons.file_upload),
          onPressed: () => load(context),
          tooltip: "Load groups",
        ),
        IconButton(
          icon: Icon(Icons.file_download),
          onPressed: grouping.groups.isNotEmpty ? () => save(context) : null,
          tooltip: "Save groups",
        ),
        IconButton(
          icon: Icon(Icons.swap_horiz),
          onPressed: selectedPositions.length == 2 ? swap : null,
          tooltip: "Swap",
        ),
        IconButton(
          icon: Icon(Icons.undo),
          onPressed: swapHistoryPointer >= 0 ? undoSwap : null,
          tooltip: "Undo swap",
        ),
        IconButton(
          icon: Icon(Icons.redo),
          onPressed:
              swapHistoryPointer < swapHistory.length - 1 ? redoSwap : null,
          tooltip: "Redo swap",
        ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: generator != null && evaluator != null
              ? () => showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => RedistributeGroupsDialog(
                          generateGroups: generateGroups,
                          context: context,
                        ),
                  )
              : null,
          tooltip: "Redistribute groups",
        ),
      ],
    );
  }

  /// load promo / class from saved csv.
  void loadPromo() async {
    final dir = await getApplicationDocumentsDirectory();
    try {
      String promo2019CSV =
          await File("${dir.path}/state/promo.csv").readAsString();
      setState(() {
        promo = Promo.fromCSV(promo2019CSV);
      });
      print("Loaded from saved.");
    } catch (e) {
      print("Failed to load.");
    }
  }

  /// save promo / class to csv.
  void savePromo() async {
    final dir = await getApplicationDocumentsDirectory();
    Directory("${dir.path}/state").createSync();
    final file = File("${dir.path}/state/promo.csv");
    file.writeAsString(promo.toCSV());
    print("Saved.");
  }
}

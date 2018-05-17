import 'dart:math';
import 'package:flutter/material.dart';
import 'package:correze_grouper/backend/utils.dart';
import 'package:correze_grouper/backend/generator.dart';
import 'package:correze_grouper/backend/evaluator.dart';
import 'package:correze_grouper/frontend/group.dart';
import 'package:correze_grouper/frontend/profile.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  List<Student> _promo = promo2019;
  List<Student> _promoUnmodified = promo2019;

  List<Student> get promo => _promo;
  set promo(List<Student> promo) {
    setState(() {
      _promo = promo;
      evaluator.promo = promo;
      generator.promo = promo;
    });
  }

  Evaluator evaluator = MeanEvaluator(promo2019);
  Generator generator = MinJealousyGenerator(promo2019);

  int groupCount = 10;
  Subject excludedSubject;

  bool loading = false;

  Grouping grouping = Grouping([]);
  List<List<String>> issues = [];

  List<StudentPos> selectedPositions = [];
  List<StudentPos> highlightedPositions = [];

  List<List<StudentPos>> swapHistory = [];
  int swapHistoryPointer = -1;

  void generateGroups() {
    setState(() {
      loading = true;
      grouping = generator.generate(
        numberOfGroups: groupCount,
      );
      issues = evaluator.findIssues(grouping);
      selectedPositions = [];
      highlightedPositions = [];
      loading = false;

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

      if (selectedPositions.length == 1) {
        highlightedPositions = locateProfile(grouping
            .groups[selectedPositions.last.groupInd]
                [selectedPositions.last.memberInd]
            .profile);
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
      if (subject != null)
        promo = _promoUnmodified
            .where((Student student) =>
                student.profile.group4Subject != subject &&
                student.profile.group6Subject != subject)
            .toList();
      else
        promo = _promoUnmodified;
    });
  }

  List<StudentPos> locateProfile(Profile profile) {
    List<StudentPos> positions = [];
    for (int groupInd = 0; groupInd < grouping.groups.length; groupInd++) {
      for (int memberInd = 0;
          memberInd < grouping.groups[groupInd].length;
          memberInd++) {
        if (grouping.groups[groupInd][memberInd].profile == profile) {
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
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.teal,
      ),
      title: "Corrèze Groupers",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Corrèze Groupers"),
        ),
        body: Column(
          children: <Widget>[
            Row(children: groupColumns),
            selectedPositions.isEmpty
                ? Row()
                : ProfilePreview(
                    profile: grouping
                        .groups[selectedPositions.last.groupInd]
                            [selectedPositions.last.memberInd]
                        .profile,
                    name: grouping
                        .groups[selectedPositions.last.groupInd]
                            [selectedPositions.last.memberInd]
                        .name,
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
                leading: Icon(Icons.group_add),
              ),
              Slider(
                value: groupCount.toDouble(),
                min: 8.0,
                max: 10.0,
                divisions: 2,
                onChanged: (double value) {
                  setState(() {
                    groupCount = value.toInt();
                  });
                },
                label: groupCount.toString(),
              ),
              ListTile(
                title: Text("Redistribute without ..."),
                leading: Icon(Icons.people_outline),
              ),
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
        persistentFooterButtons: <Widget>[
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: null,
            tooltip: "Save grouping",
          ),
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: null,
            tooltip: "Load grouping",
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
            onPressed: loading ? null : generateGroups,
            tooltip: "Redistribute groups",
          ),
        ],
      ),
    );
  }
}

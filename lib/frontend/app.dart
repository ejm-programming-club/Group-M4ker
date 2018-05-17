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
  List<Student> promo = promo2019;
  Evaluator evaluator = MeanEvaluator(promo2019);
  Generator generator = MinJealousyGenerator(promo2019);

  int groupCount = 10;

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
    return new MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.teal,
      ),
      title: "Corrèze Groupers",
      home: Scaffold(
        appBar: new AppBar(
          title: Text("Corrèze Groupers"),
        ),
        body: new Column(
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
        floatingActionButton: loading ? CircularProgressIndicator() : null,
        persistentFooterButtons: <Widget>[
          new IconButton(
            icon: Icon(Icons.file_download),
            onPressed: null,
          ),
          new IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: null,
          ),
          new IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: selectedPositions.length == 2 ? swap : null,
          ),
          new IconButton(
            icon: Icon(Icons.undo),
            onPressed: swapHistoryPointer >= 0 ? undoSwap : null,
          ),
          new IconButton(
            icon: Icon(Icons.redo),
            onPressed:
                swapHistoryPointer < swapHistory.length - 1 ? redoSwap : null,
          ),
          new IconButton(
            icon: Icon(Icons.settings),
            onPressed: null,
          ),
          new IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loading ? null : generateGroups,
          ),
        ],
      ),
    );
  }
}

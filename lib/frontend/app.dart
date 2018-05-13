import 'dart:math';
import 'package:flutter/material.dart';
import 'package:correze_grouper/backend/utils.dart';
import 'package:correze_grouper/backend/generators.dart';
import 'package:correze_grouper/frontend/group.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  List<Student> promo = promo2019;
  Evaluator evaluator = MeanEvaluator(promo2019);
  Generator generator = MinJealousyGenerator(promo2019);

  int groupCount = 10;

  // TODO Actually the generation is so fast that this is useless.
  double progress = 0.0;
  Grouping grouping = Grouping([]);
  List<List<String>> issues = [];

  List<StudentPos> selectedPositions = [];
  List<StudentPos> highlightedPositions = [];

  void generateGroups() {
    setState(() {
      grouping = generator.generate(
        numberOfGroups: groupCount,
        pBarUpdateCallback: (double p) => setState(() => progress = p),
      );
      issues = evaluator.findIssues(grouping);
      selectedPositions = [];
      highlightedPositions = [];
    });
  }

  void swap() {
    if (selectedPositions.length != 2) return;
    setState(() {
      grouping.swap(selectedPositions[0], selectedPositions[1]);
    });
  }

  void select(StudentPos pos) {
    setState(() {
      if (selectedPositions.contains(pos))
        selectedPositions.remove(pos);
      else {
        if (selectedPositions.length == 2) selectedPositions.removeLast();
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
    List<Column> groupColumns = [];
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
            Row(
              children: groupColumns,
            ),
          ],
        ),
        persistentFooterButtons: <Widget>[
          new IconButton(icon: Icon(Icons.refresh), onPressed: generateGroups)
        ],
      ),
    );
  }
}

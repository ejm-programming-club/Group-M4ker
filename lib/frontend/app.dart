import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:correze_grouper/backend/utils.dart';
import 'package:correze_grouper/backend/generator.dart';
import 'package:correze_grouper/backend/evaluator.dart';
import 'package:correze_grouper/frontend/dialogs.dart';
import 'package:correze_grouper/frontend/group.dart';
import 'package:correze_grouper/frontend/profile.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.teal,
      ),
      title: "Corrèze Groupers",
      home: Grouper(),
    );
  }
}

class Grouper extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GrouperState();
}

class _GrouperState extends State<Grouper> {
  List<Student> _promo;
  List<Student> _promoUnmodified;

  List<Student> get promo => _promo;

  set promo(List<Student> promo) {
    setState(() {
      _promo = promo;
      evaluator.promo = promo;
      generator.promo = promo;
    });
  }

  _GrouperState() {
    _promo = _promoUnmodified = promo2019;

    evaluator = MeanEvaluator(promo);
    generator = MinJealousyGenerator(promo);
  }

  Evaluator evaluator;
  Generator generator;

  int groupCount = 10;
  Subject excludedSubject;

  Grouping grouping = Grouping([]);
  List<List<String>> issues = [];

  List<StudentPos> selectedPositions = [];
  List<StudentPos> highlightedPositions = [];

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

  void load(BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    List<String> saves;

    try {
      final file = File("$path/saved.json");
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
    await file.writeAsString(grouping.toString());

    final savesFile = File("$path/saved.json");
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
    final List<List<String>> groups =
        (jsonDecode(await file.readAsString()) as List)
            .map((ls) => (ls as List).cast<String>())
            .toList();

    setState(() {
      loadedFilename = filename;
      grouping = fromList(_promoUnmodified, groups);
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
    return Scaffold(
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
              subtitle: Slider(
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
              title: Text("Information"),
              leading: Icon(Icons.help),
              onTap: () => null,
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
          onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => RedistributeGroupsDialog(
                      generateGroups: generateGroups,
                      context: context,
                    ),
              ),
          tooltip: "Redistribute groups",
        ),
      ],
    );
  }
}

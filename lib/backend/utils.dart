import 'package:flutter/foundation.dart';
import 'package:group_m4ker/frontend/dialogs.dart';

enum Gender { M, F }
enum Level { SL, HL }
enum Subject { BIO, CHM, PHY }

/// The profile of a student, containing information about one's
/// gender, subject (biology, chemistry, physics) levels (SL / HL),
/// and leadership skills.
class Profile {
  Gender gender;
  Level bioLevel, chmLevel, phyLevel;
  bool isStrongLeader;

  Profile({
    @required this.gender,
    @required this.bioLevel,
    @required this.chmLevel,
    @required this.phyLevel,
    @required this.isStrongLeader,
  });

  @override
  bool operator ==(other) {
    return other is Profile &&
        gender == other.gender &&
        bioLevel == other.bioLevel &&
        chmLevel == other.chmLevel &&
        phyLevel == other.phyLevel &&
        isStrongLeader == other.isStrongLeader;
  }

  @override
  int get hashCode => super.hashCode;
}

/// A student defined by his/her name and [Profile].
class Student {
  Profile profile;
  String name;

  Student({this.profile, this.name});

  /// Utility method to check if this student is taking the specified [Subject].
  bool takes(Subject subject) {
    return {
          Subject.BIO: profile.bioLevel,
          Subject.CHM: profile.chmLevel,
          Subject.PHY: profile.phyLevel,
        }[subject] !=
        null;
  }

  Student copy() {
    return Student(
      name: name,
      profile: Profile(
        isStrongLeader: profile.isStrongLeader,
        gender: profile.gender,
        bioLevel: profile.bioLevel,
        chmLevel: profile.chmLevel,
        phyLevel: profile.phyLevel,
      ),
    );
  }

  @override
  bool operator ==(other) {
    return other is Student && other.name == name && other.profile == profile;
  }

  @override
  int get hashCode => super.hashCode;
}

class StudentPos {
  final int groupInd, memberInd;
  static final Map<int, StudentPos> _cache = {};

  StudentPos._internal(this.groupInd, this.memberInd);

  factory StudentPos(int groupInd, int memberInd) {
    int hashCode =
        identityHashCode(groupInd) + identityHashCode(memberInd) * 31;
    if (!_cache.containsKey(hashCode))
      _cache[hashCode] = StudentPos._internal(groupInd, memberInd);
    return _cache[hashCode];
  }
}

/// An arrangement of groups of students.
class Grouping {
  final List<List<Student>> groups;

  Grouping(this.groups);

  Grouping.fromList({@required dynamic listOfGroups, @required Promo promo})
      : groups = [] {
    for (List<dynamic> group in listOfGroups) {
      List<Student> currentGroup = [];
      for (dynamic studentName in group) {
        Student student = promo.findByName(studentName as String);
        if (student == null) throw Exception;
        currentGroup.add(student);
      }
      groups.add(currentGroup);
    }
  }

  void swap(StudentPos pos1, StudentPos pos2) {
    Student temp = groups[pos1.groupInd][pos1.memberInd];
    groups[pos1.groupInd][pos1.memberInd] =
        groups[pos2.groupInd][pos2.memberInd];
    groups[pos2.groupInd][pos2.memberInd] = temp;
  }

  @override
  String toString() {
    return "[" +
        groups
            .map((members) =>
                "\n  [" +
                members
                    .map((member) => '"' + member.name.toString() + '"')
                    .join(", ") +
                "]")
            .join(',') +
        "\n]";
  }
}

class GroupStats {
  final int maleCount;
  final int femaleCount;
  final int bioCount;
  final int chmCount;
  final int phyCount;
  final int slCount;
  final int hlCount;
  final int strongLeadersCount;

  GroupStats({
    this.maleCount,
    this.femaleCount,
    this.bioCount,
    this.chmCount,
    this.phyCount,
    this.slCount,
    this.hlCount,
    this.strongLeadersCount,
  });

  factory GroupStats.of(List<Student> group) {
    int maleCount = 0;
    int femaleCount = 0;
    int bioCount = 0;
    int chmCount = 0;
    int phyCount = 0;
    int slCount = 0;
    int hlCount = 0;
    int strongLeadersCount = 0;

    for (final Student student in group) {
      final Profile profile = student.profile;
      if (profile.gender == Gender.M)
        maleCount++;
      else
        femaleCount++;

      if (profile.bioLevel != null) {
        bioCount++;
        if (profile.bioLevel == Level.SL)
          slCount++;
        else
          hlCount++;
      }

      if (profile.chmLevel != null) {
        chmCount++;
        if (profile.chmLevel == Level.SL)
          slCount++;
        else
          hlCount++;
      }

      if (profile.phyLevel != null) {
        phyCount++;
        if (profile.phyLevel == Level.SL)
          slCount++;
        else
          hlCount++;
      }

      if (profile.isStrongLeader) strongLeadersCount++;
    }

    return GroupStats(
      maleCount: maleCount,
      femaleCount: femaleCount,
      bioCount: bioCount,
      chmCount: chmCount,
      phyCount: phyCount,
      slCount: slCount,
      hlCount: hlCount,
      strongLeadersCount: strongLeadersCount,
    );
  }
}

/// Une promotion des étudiants / class of a certain year / 一届学生
class Promo {
  final List<Student> students;

  Promo(this.students);

  Promo.fromCSV(String csv, {ArgCallback<List<String>> reportColumns})
      : students = [] {
    int nameIndex, genderIndex, leadershipIndex, bioIndex, chmIndex, phyIndex;
    List<String> rows = csv.split("\n");
    if (rows.length <= 1) throw Exception;
    List<String> headers = rows[0].split(",");
    for (final e in headers.asMap().entries) {
      String header = e.value.toUpperCase().replaceAll(" ", "");
      if (nameIndex == null &&
          (header.contains("NAME") || header.contains("STUDENT"))) {
        nameIndex = e.key;
        continue;
      }
      if (genderIndex == null &&
          (header.contains("GENDER") ||
              header.contains("M/F") ||
              header.contains("SEX"))) {
        genderIndex = e.key;
        continue;
      }
      if (leadershipIndex == null && header.contains("LEADER")) {
        leadershipIndex = e.key;
        continue;
      }
      if (bioIndex == null && header.contains("BIO")) {
        bioIndex = e.key;
        continue;
      }
      if (chmIndex == null && header.contains("CHM")) {
        chmIndex = e.key;
        continue;
      }
      if (phyIndex == null && header.contains("PHY")) {
        phyIndex = e.key;
        continue;
      }
    }

    List<String> studentRows = rows.sublist(1);
    for (String studentRow in studentRows) {
      List<String> studentInfo = studentRow.split(",");
      students.add(Student(
        name: nameIndex != null ? studentInfo[nameIndex] : "",
        profile: Profile(
          gender: genderIndex != null
              ? (studentInfo[genderIndex].toUpperCase() == "M"
                  ? Gender.M
                  : studentInfo[genderIndex].toUpperCase() == "F"
                      ? Gender.F
                      : null)
              : null,
          isStrongLeader: leadershipIndex != null
              ? studentInfo[leadershipIndex].isNotEmpty
              : false,
          bioLevel: bioIndex != null
              ? studentInfo[bioIndex].toUpperCase() == "SL"
                  ? Level.SL
                  : studentInfo[bioIndex].toUpperCase() == "HL"
                      ? Level.HL
                      : null
              : null,
          chmLevel: bioIndex != null
              ? studentInfo[chmIndex].toUpperCase() == "SL"
                  ? Level.SL
                  : studentInfo[chmIndex].toUpperCase() == "HL"
                      ? Level.HL
                      : null
              : null,
          phyLevel: bioIndex != null
              ? studentInfo[phyIndex].toUpperCase() == "SL"
                  ? Level.SL
                  : studentInfo[phyIndex].toUpperCase() == "HL"
                      ? Level.HL
                      : null
              : null,
        ),
      ));

      if (reportColumns != null) {
        reportColumns([
          "The following columns are identified:",
          "",
          "Name: ${nameIndex == null ? 'MISSING' : headers[nameIndex]}",
          "Gender: ${genderIndex == null ? 'MISSING' : headers[genderIndex]}",
          "Leadership: ${leadershipIndex == null
              ? 'MISSING'
              : headers[leadershipIndex]}",
          "Biology level: ${bioIndex == null ? 'MISSING' : headers[bioIndex]}",
          "Chemistry level: ${chmIndex == null
              ? 'MISSING'
              : headers[chmIndex]}",
          "Physics level: ${phyIndex == null ? 'MISSING' : headers[phyIndex]}",
          "",
          "Missing information can be added at Menu (top left) > View / Edit class.",
        ]);
      }
    }
  }

  String toCSV() {
    List<String> csvRows = [];

    // Header
    csvRows.add([
      "Name",
      "Gender",
      "Leadereship",
      "Bio level",
      "Chm level",
      "Phy level",
    ].join(","));

    // Students
    for (Student student in students) {
      csvRows.add([
        student.name,
        student.profile.gender.toString().split(".").last,
        student.profile.isStrongLeader ? "Yes" : "",
        (student.profile.bioLevel ?? "").toString().split(".").last,
        (student.profile.chmLevel ?? "").toString().split(".").last,
        (student.profile.phyLevel ?? "").toString().split(".").last,
      ].join(","));
    }
    return csvRows.join("\n");
  }

  Student findByName(String name) {
    for (Student student in students) {
      if (student.name == name) {
        return student;
      }
    }
    return null;
  }
}
